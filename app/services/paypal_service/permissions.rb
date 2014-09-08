module PaypalService
  class Permissions

    def initialize(endpoint, api_credentials)
      PayPal::SDK.configure({
        mode: endpoint.endpoint_name.to_s,
        username: api_credentials.username,
        password: api_credentials.password,
        signature: api_credentials.signature,
        app_id: api_credentials.app_id
      })

      @api = PayPal::SDK::Permissions::API.new
    end

    def do_request(request)
      return do_request_permissions(request) if request.method == :RequestPermissions

      raise(ArgumentException, "Unknown request method #{request.method}")
    end

    private

    def do_request_permissions(request_permissions)
      req = @api.build_request_permissions({
          :scope => request_permissions.scope,
          :callback => request_permissions.callback
       })
      res = @api.request_permissions(req)

      if (res.success?)
        DataTypes::Permissions.create_req_perm_response(request_permissions.scope, res.token, @api.grant_permission_url(res))
      else
        if (res.error.length > 0)
          DataTypes::Permissions.create_failed_req_perm_response(res.error[0].error_id, res.error[0].message)
        else
          DataTypes::Permissions.create_failed_req_perm_response()
        end
      end
    end
  end
end
