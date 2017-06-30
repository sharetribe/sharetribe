class HarmonyProxyController < ApplicationController

  skip_before_action :cannot_access_without_confirmation, :ensure_consent_given
  skip_before_action :verify_authenticity_token

  # OR can be used to combine authorization methods using "OR" logic.
  # It takes any number of authorization methods. OR is a normal
  # lambda, so you can call it with `.call()`. Keep in mind, that
  # for lambdas, `[]` is alias for `call()`
  #
  # Usage:
  #
  # {
  #   authorization: OR[
  #     IsAdmin,
  #     IsListingAuthor,
  #     IsFriday
  #   ]
  # }
  #
  OR = ->(*auth_methods) {
    ->(*args) {
      auth_methods.any? { |auth_method| auth_method.call(*args) }
    }
  }

  AND = ->(*auth_methods) {
    ->(*args) {
      auth_methods.all? { |auth_method| auth_method.call(*args) }
    }
  }

  # Return `true` if the caller is marketplace admin
  module IsAdmin
    module_function

    def call(req, auth_context)
      auth_context[:actorRole] == :admin
    end
  end

  module IsMarketplaceMember
    module_function

    def call(req, auth_context)
      marketplace_id =
        case req[:method]
        when "GET"
          req[:query_params][:marketplaceId]
        when "POST"
          req[:body][:marketplaceId].to_s
        end

      auth_context[:marketplaceId] == marketplace_id
    end
  end

  # Return `true` if the caller is listing author. Check for following
  # params (body or query):
  #
  # - refId (listing uuid)
  # - marketplaceId (marketplace uuid)
  #
  module IsListingAuthor
    module_function

    def call(req, auth_context)
      ref_id =
        case req[:method]
        when "GET"
          UUIDTools::UUID.parse(req[:query_params][:refId])
        when "POST"
          req[:body][:refId]
        end

      return false if ref_id.nil?

      raw_uuid = UUIDUtils.raw(ref_id)
      listing = Listing.find_by(uuid: raw_uuid)

      if listing.nil?
        false
      else
        author_uuid = listing.author.uuid_object.to_s
        auth_context[:actorId] == author_uuid
      end
    end
  end

  EndpointDefinition = EntityUtils.define_builder(
    [:name, :symbol, :mandatory],
    [:login_needed, :bool, :mandatory],
    [:authorization, :callable, :mandatory])

  # Define here all the endpoints that you want to forward to Harmony
  #
  # The endpoint definition has contains following values:
  #
  # - name: This is the endpoint name as a symbol. The name MUST match to one
  #         of the endpoints in the Harmony Client endpoint map.
  # - login_needed: if `false`, this endpoint can be accessed by unlogged user
  # - authorization: A callable, which is called with two params, req and
  #                  auth_context. The function should return `true` if the user
  #                  is allowed to perform the given action, otherwise `false`
  #
  FORWARDABLE_ENDPOINTS = [
    {
      name: :show_bookable,
      login_needed: true,
      authorization: AND[IsMarketplaceMember, OR[IsListingAuthor, IsAdmin]],
    },
    {
      name: :create_blocks,
      login_needed: true,
      authorization: AND[IsMarketplaceMember, OR[IsListingAuthor, IsAdmin]],
    },
    {
      name: :delete_blocks,
      login_needed: true,
      authorization: AND[IsMarketplaceMember, OR[IsListingAuthor, IsAdmin]],
    }

    # Add here all whitelisted actions

  ].map { |ep_def| EndpointDefinition.call(ep_def) }

  TRANSIT_JSON_MIME = "application/transit+json"

  # List of expected headers
  EXPECTED_HEADERS = {
    "Content-Type" => TRANSIT_JSON_MIME,
    "Accept" => TRANSIT_JSON_MIME
  }

  # This is the main method of the HarmonyProxyController
  #
  # The purpose of the controller is to forward all calls to it to
  # Harmony service and authrize the requests before forwarding them.
  #
  # Errors (from the proxy):
  #
  # - 404: Endpoint not found
  # - 401: Authentication needed, but user is not logged in
  # - 403: Authorization failed
  #
  # If there are no errors from the proxy (auth passed and call forwarded),
  # the result from Harmony is forwarded to client unchanged (with the same body and status)
  #
  def proxy
    # Validate headers and build `ctx`
    ctx = validate_headers(request)
            .and_then(&method(:build_request_context))

    # Pipe `ctx` through following methods
    result = ctx.and_then(&method(:find_endpoint))
               .and_then(&method(:authenticate))
               .and_then(&method(:authorize))
               .and_then(&method(:call_harmony))

    # Handle result
    result
      .on_success(&method(:success))
      .on_error(&method(:error))
  end

  private

  def success(ctx)
    render json: ctx[:response][:body], status: ctx[:response][:status]
  end

  def error(error_msg, ctx)
    render plain: error_msg, status: ctx[:error][:status]
  end

  def validate_headers(request)
    missing_header = EXPECTED_HEADERS.to_a.find { |k, v|
      request.headers[k] != v
    }

    if missing_header.nil?
      Result::Success.new(request)
    else
      name, expected = missing_header
      actual = request.headers[name]
      Result::Error.new("Expected header '#{name}' with value '#{expected}', got '#{actual}'")
    end
  end

  def build_request_context(request)
    path = request.path_parameters[:harmony_path]
    format = request.path_parameters[:format] ? "." + request.path_parameters[:format] : ""
    raw_body = request.body.read
    body_params = TransitUtils.decode(raw_body, :json) || {}

    Result::Success.new(
      request: {
        method: request.method,
        path: "/" + path + format,
        query_params: request.query_parameters,
        body: body_params,
        raw_body: raw_body
      })
  end

  def call_harmony(ctx)
    req, endpoint = ctx.values_at(:request, :endpoint)

    # The client is sending data in transit_json format.
    # Since the proxy just forwards the request/response,
    # we want to skip decoding and encoding.
    opts = { encoding: :transit_json,
             decode_response: false,
             encode_request: false }

    res =
      case req[:method]
      when "GET"
        HarmonyClient.get(endpoint[:name], params: req[:query_params], opts: opts)
      when "POST"
        HarmonyClient.post(endpoint[:name], params: req[:query_params], body: req[:raw_body], opts: opts)
      else
        raise ArgumentError.new("Unknown method: #{req[:method]}")
      end

    res.and_then { |response|
      Result::Success.new(ctx.merge(response: response))
    }.rescue { |error_msg, data|

      if data[:status]
        # Server returned an error code
        Result::Error.new(error_msg, ctx.merge(error: { status: data[:status] }))
      else
        # Unknown error, e.g. timeout
        Result::Error.new("Internal error", ctx.merge(error: { status: 500 }))
      end

    }
  end

  # Authorize the user:
  #
  # - Call the endpoint's `authorization` function
  # - Return 403, if `authorization` function returns `false`
  #
  def authorize(ctx)
    req, endpoint, auth_context = ctx.values_at(:request, :endpoint, :auth_context)

    if !endpoint[:authorization].call(req, auth_context)
      Result::Error.new("Forbidden", ctx.merge(error: { status: 403 }))
    else
      Result::Success.new(ctx)
    end
  end

  # Authenticate the user:
  #
  # - If login is needed, but user is not logged in, return 401
  # - Else, create auth_context from @current_user
  #
  def authenticate(ctx)
    if ctx[:endpoint][:login_needed] == true && @current_user.nil?
      Result::Error.new("Unauthorized", ctx.merge(error: { status: 401 }))
    else
      auth_context = create_auth_context(user: @current_user, community: @current_community)
      Result::Success.new(ctx.merge(auth_context: auth_context))
    end
  end

  def find_endpoint(ctx)
    harmony_endpoint = HarmonyEndpoints::ENDPOINT_MAP.find { |endpoint_name, path|
      path == ctx[:request][:path]
    }

    endpoint_name = Maybe(harmony_endpoint).map { |ep| ep.first }.or_else(nil)

    endpoint = FORWARDABLE_ENDPOINTS.find { |ep|
      ep[:name] == endpoint_name
    }

    if endpoint.present?
      Result::Success.new(ctx.merge(endpoint: endpoint))
    else
      Result::Error.new("Not found", ctx.merge(error: { status: 404 }))
    end
  end

  def create_auth_context(user:, community:)
    {
      marketplaceId: community.uuid_object.to_s,
      actorId: (user&.uuid_object || UUIDUtils.v0_uuid).to_s,
      actorRole: role(user, community)
    }
  end

  def role(user, community)
    if user.nil?
      nil
    elsif user.has_admin_rights?(community)
      :admin
    else
      :user
    end
  end
end
