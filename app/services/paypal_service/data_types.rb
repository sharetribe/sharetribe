module PaypalService
  module DataTypes
    Endpoint = Struct.new(:endpoint_name) # One of :live or :sandbox
    APICredentials = Struct.new(:username, :password, :signature, :app_id)


    module_function

    def create_endpoint(type)
      raise(ArgumentError, "type must be either :live or :sandbox") unless [:live, :sandbox].include?(type)
      Endpoint.new(type)
    end

    def create_api_credentials(username, password, signature, app_id)
      raise(ArgumentError, "username, password, signature and app_id are all mandatory.") unless none_empty?(username, password, signature, app_id)
      APICredentials.new(username, password, signature, app_id)
    end

    def none_empty?(*args)
      args.map(&:to_s).reject(&:empty?).length == args.length
    end

    module Permissions
      RequestPermissions = Struct.new(:method, :scope, :callback)
      RequestPermissionsSuccessResponse = Struct.new(:success, :scope, :request_token, :redirect_url)
      RequestPermissionsFailureResponse = Struct.new(:success, :error_id, :error_msg)


      module_function

      def create_req_perm(callback)
        raise(ArgumentError, "callback is mandatory") unless DataTypes.none_empty?(callback)

        RequestPermissions.new(
          :RequestPermissions,
          [
            "EXPRESS_CHECKOUT",
            "AUTH_CAPTURE",
            "REFUND",
            "TRANSACTION_DETAILS",
            "EXPRESS_CHECKOUT",
            "RECURRING_PAYMENTS",
            "SETTLEMENT_REPORTING",
            "RECURRING_PAYMENT_REPORT"
          ],
          callback)
      end

      def create_req_perm_response(scope, token, redirect_url)
        raise(ArgumentError, "scope, token and redirect_url are all mandatory") unless DataTypes.none_empty?(scope, token, redirect_url)

        RequestPermissionsSuccessResponse.new(true, scope, token, redirect_url)
      end

      def create_failed_req_perm_response(error_id, error_msg)
        RequestPermissionsFailureResponse.new(false, error_id, error_msg)
      end
    end
  end
end
