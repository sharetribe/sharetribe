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
      ),

      get_access_token: PaypalAction.def_action(
        input_transformer: -> (req) {
          {
            token: req[:request_token],
            verifier: req[:verification_code]
          }
        },
        wrapper_method_name: :build_get_access_token,
        action_method_name: :get_access_token,
        output_transformer: -> (res, api) {
          DataTypes::Permissions.create_get_access_token_response({
            scope: res.scope,
            token: res.token,
            token_secret: res.token_secret
          })
        }
      ),

      get_basic_personal_data: PaypalAction.def_action(
        input_transformer: -> (req) {
          {
            attributeList: {
                attribute: [ "http://axschema.org/contact/email", "https://www.paypal.com/webapps/auth/schema/payerID" ]
            }
          }
        },
        wrapper_method_name: nil,
        action_method_name: :get_basic_personal_data,
        output_transformer: -> (res, api) {
          data = res.response.personal_data.to_ary
            .map { |pdata| [pdata.personal_data_key, pdata.personal_data_value] }
            .to_h

          DataTypes::Permissions.create_get_basic_personal_data_response({
            email: data["http://axschema.org/contact/email"],
            payer_id: data["https://www.paypal.com/webapps/auth/schema/payerID"]
          })
        }
      )
    }

  end
end
