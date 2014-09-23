module PaypalService
  module PermissionsActions

    PERMISSIONS_ACTIONS = {
      request_permissions: PaypalAction.def_action(
        input_transformer: -> (req) {
          {
            scope: req[:scope],
            callback: req[:callback]
          }
        },
        wrapper_method_name: :build_request_permissions,
        action_method_name: :request_permissions,
        output_transformer: -> (res, api) {
          DataTypes::Permissions.create_req_perm_response({
            username_to: api.config.username,
            request_token: res.token,
            redirect_url: api.grant_permission_url(res)
          })
        }
      )
    }

  end
end
