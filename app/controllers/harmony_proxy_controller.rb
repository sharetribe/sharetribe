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

      auth_context[:marketplaceId] == q[:marketplaceId]
      auth_context[:actorId] == author_uuid
    end
  end

  EndpointDefinition = EntityUtils.define_builder(
    [:name, :symbol, :mandatory],
    [:required_role, :mandatory, one_of: [:none, :user, :admin]],
    [:authorization, :callable, :mandatory])

  # Define here all the endpoints that you want to forward to Harmony
  #
  # The endpoint definition has contains following values:
  #
  # - name: This is the endpoint name as a symbol. The name MUST match to one
  #         of the endpoints in the Harmony Client endpoint map.
  # - required_role: The minimum role that is required to the action.
  #                  Available roles are :none, :user and :admin, where
  #                  :none < :user < :admin
  # - authorization: A callable, which is called with two params, req and
  #                  auth_context. The function should return `true` if the user
  #                  is allowed to perform the given action, otherwise `false`
  #
  ENDPOINTS = [
    {
      name: :show_bookable,
      required_role: :user,
      authorization: AuthorizeShowBookable
    }

    # Add here all whitelisted actions

  ].map { |ep_def| EndpointDefinition.call(ep_def) }

  # This is the main method of the HarmonyProxyController
  #
  # The purpose of the controller is to forward all calls to it to
  # Harmony service and authrize the requests before forwarding them.
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
    render json: res[:body], status: ctx[:response][:status]
  end

  def error(error_msg, ctx)
    render plain: error_msg, status: ctx[:error][:status]
  end

  def build_request_context(request)
    path = request.path_parameters[:path]
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

  def authorize(ctx)
    req, endpoint, auth_context = ctx.values_at(:request, :endpoint, :auth_context)

    if role_unauthorized?(endpoint, auth_context)
      Result::Error.new("Forbidden", ctx.merge(error: { status: 403 }))
    elsif !endpoint[:authorization].call(req, auth_context)
      Result::Error.new("Forbidden", ctx.merge(error: { status: 403 }))
    else
      Result::Success.new(ctx)
    end
  end

  def authenticate(ctx)
    if ctx[:endpoint][:required_role] != :none && @current_user.nil?
      Result::Error.new("Unauhtorized", ctx.merge(error: { status: 401 }))
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

    endpoint = ENDPOINTS.find { |endpoint|
      endpoint[:name] == endpoint_name
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

  def role_unauthorized?(endpoint, auth_context)
    !expanded_role(auth_context[:actorRole]).include?(endpoint[:required_role])
  end

  def expanded_role(role)
    case role
    when :user
      [:none, :user]
    when :admin
      [:none, :user, :admin]
    else
      [role]
    end
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
