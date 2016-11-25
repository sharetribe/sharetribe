class HarmonyProxyController < ApplicationController

  skip_filter :cannot_access_without_confirmation, :ensure_consent_given
  skip_before_filter :verify_authenticity_token

  module AuthorizeShowBookable
    module_function

    def call(req, auth_context)
      q = req[:query_params]

      raw_uuid = UUIDUtils.raw(UUIDTools::UUID.parse(q[:refId]))
      listing = Listing.find_by(uuid: raw_uuid)

      return false if listing.nil?

      author_uuid = listing.author.uuid_object.to_s

      auth_context[:marketplaceId] == q[:marketplaceId] &&
        auth_context[:actorId] == author_uuid
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
      authorization: AuthorizeShowBookable
    }

    # Add here all whitelisted actions

  ].map { |ep_def| EndpointDefinition.call(ep_def) }

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
    build_request_context(request)
      .and_then(&method(:find_endpoint))
      .and_then(&method(:authenticate))
      .and_then(&method(:authorize))
      .and_then(&method(:call_harmony))
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

  def build_request_context(request)
    path = request.path_parameters[:harmony_path]
    format = request.path_parameters[:format] ? "." + request.path_parameters[:format] : ""

    Result::Success.new(
      request: {
        method: request.method,
        path: "/" + path + format,
        query_params: request.query_parameters,
        body: request.request_parameters
      })
  end

  def call_harmony(ctx)
    req, endpoint = ctx.values_at(:request, :endpoint)

    res =
      case req[:method]
      when "GET"
        HarmonyClient.get(endpoint[:name], params: req[:query_params], opts: { encoding: :json })
      when "POST"
        HarmonyClient.post(endpoint[:name], params: req[:query_params], body: req[:body], opts: { encoding: :json })
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
      actorRole: role(user)
    }
  end

  def role(user)
    if user.nil?
      nil
    elsif user.has_admin_rights?
      :admin
    else
      :user
    end
  end
end
