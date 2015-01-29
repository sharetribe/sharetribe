require_relative 'test_api'

module PaypalService

  module TestPermissions
    def self.build(api_builder)
      PaypalService::Permissions.new(nil, TestLogger.new, TestPermissionsActions.new.default_test_actions, api_builder)
    end
  end

  class TestPermissionsActions
    attr_reader :default_test_actions

    def initialize
      @default_test_actions = build_default_test_actions
    end

    def build_default_test_actions
      identity = -> (val) { val }
      {
        request_permissions: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            token = "12345" # This could be saved to "fake pal", if needed
            DataTypes::Permissions.create_req_perm_response(
              {
                username_to: api.config.subject,
                request_token: token,
                redirect_url: "https://paypaltest.com/#{token}"
              })
          }
        ),
        get_access_token: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            token = "12345" # This could be saved to "fake pal", if needed
            DataTypes::Permissions.create_get_access_token_response(
              {
                scope: ["TEST_SCOPE1", "TEST_SCOPE2"],
                token: token,
                token_secret: "12345_secret"
              })
          }
        ),
        get_basic_personal_data: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            DataTypes::Permissions.create_get_basic_personal_data_response(
              {
                email: "payer_email@example.com",
                payer_id: "payer_id"
              })
          }
        )
      }
    end
  end
end
