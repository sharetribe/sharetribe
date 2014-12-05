module PaypalService
  module DataTypes

    module Permissions
      RequestPermissions = EntityUtils.define_builder(
        [:method, const_value: :request_permissions],
        [:scope, const_value:
          [
            "EXPRESS_CHECKOUT",
            "AUTH_CAPTURE",
            "REFUND",
            "TRANSACTION_DETAILS",
            "EXPRESS_CHECKOUT",
            "ACCESS_BASIC_PERSONAL_DATA"
          ]
        ],
        [:callback, :mandatory, :string])

      RequestPermissionsResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:username_to, :mandatory, :string],
        [:request_token, :mandatory, :string],
        [:redirect_url, :mandatory, :string])

      GetAccessToken = EntityUtils.define_builder(
        [:method, const_value: :get_access_token],
        [:request_token, :mandatory, :string],
        [:verification_code, :mandatory, :string])

      GetAccessTokenResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:scope, :mandatory, :enumerable],
        [:token, :mandatory, :string],
        [:token_secret, :mandatory, :string])

      GetBasicPersonalData = EntityUtils.define_builder(
        [:method, const_value: :get_basic_personal_data],
        [:token, :mandatory, :string],
        [:token_secret, :mandatory, :string])

      GetBasicPersonalDataResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:email, :mandatory, :string],
        [:payer_id, :mandatory, :string])


      module_function

      def create_req_perm(opts); RequestPermissions.call(opts) end
      def create_req_perm_response(opts); RequestPermissionsResponse.call(opts) end

      def create_get_access_token(opts); GetAccessToken.call(opts) end
      def create_get_access_token_response(opts); GetAccessTokenResponse.call(opts) end

      def create_get_basic_personal_data(opts); GetBasicPersonalData.call(opts) end
      def create_get_basic_personal_data_response(opts); GetBasicPersonalDataResponse.call(opts) end

    end

  end
end
