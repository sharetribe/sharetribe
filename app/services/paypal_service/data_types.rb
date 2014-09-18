module PaypalService
  module DataTypes
    Endpoint = EntityUtils.define_builder([:endpoint_name, one_of: [:live, :sandbox]])
    APICredentials = EntityUtils.define_builder(
      [:username, :mandatory, :string],
      [:password, :mandatory, :string],
      [:signature, :mandatory, :string],
      [:app_id, :mandatory, :string])

    FailureResponse = EntityUtils.define_builder(
      [:success, const_value: false],
      [:error_code, :string],
      [:error_msg, :string])


    module_function

    def create_endpoint(opts); Endpoint.call(opts) end
    def create_api_credentials(opts); APICredentials.call(opts) end
    def create_failure_response(opts); FailureResponse.call(opts) end

    module Merchant
      SetupBillingAgreement = Struct.new(:method, :description, :success, :cancel)
      SetupBillingAgreementResponse = Struct.new(:success, :token, :redirect_url, :username_to)

      CreateBillingAgreement = Struct.new(:method, :token)
      CreateBillingAgreementResponse = Struct.new(:success, :billing_agreement_id)

      # order_total should be string. Use . as separator. E.g. 1.15
      DoReferenceTransaction = Struct.new(:method, :receiver_username, :billing_agreement_id, :order_total, :currency)
      DoReferenceTransactionResponse = Struct.new(:success, :billing_agreement_id, :transaction_id, :gross_amount, :gross_currency, :fee_amount, :fee_currency, :username_to)


      module_function

      def create_setup_billing_agreement(description, success, cancel)
        ParamUtils.throw_if_any_empty({description: description, success: success, cancel: cancel})

        SetupBillingAgreement.new(
          :setup_billing_agreement,
          description,
          success,
          cancel)
      end

      def create_setup_billing_agreement_response(token, redirect_url, username_to)
        ParamUtils.throw_if_any_empty({token: token, redirect_url: redirect_url})
        SetupBillingAgreementResponse.new(true, token, redirect_url, username_to)
      end

      def create_create_billing_agreement(token)
        ParamUtils.throw_if_any_empty({token: token})
        CreateBillingAgreement.new(:create_billing_agreement, token)
      end

      def create_create_billing_agreement_response(billing_agreement_id)
        ParamUtils.throw_if_any_empty({billing_agreement_id: billing_agreement_id})
        CreateBillingAgreementResponse.new(true, billing_agreement_id)
      end

      def create_do_reference_transaction(receiver_username, billing_agreement_id, order_total, currency)
        ParamUtils.throw_if_any_empty({
            receiver_username: receiver_username,
            billing_agreement_id: billing_agreement_id,
            order_total: order_total,
            currency: currency
          })
        DoReferenceTransaction.new(:do_reference_transaction, receiver_username, billing_agreement_id, order_total, currency)
      end


      def create_do_reference_transaction_response(billing_agreement_id, transaction_id, gross_amount, gross_currency, fee_amount, fee_currency, username_to)
        ParamUtils.throw_if_any_empty({
            billing_agreement_id: billing_agreement_id,
            transaction_id: transaction_id,
            gross_amount: gross_amount,
            gross_currency: gross_currency,
            fee_amount: fee_amount,
            fee_currency: fee_currency,
            username_to: username_to
          })

        DoReferenceTransactionResponse.new(true, billing_agreement_id, transaction_id, gross_amount, gross_currency, fee_amount, fee_currency, username_to)
      end
    end

    module Permissions
      RequestPermissions = Struct.new(:method, :scope, :callback)
      RequestPermissionsSuccessResponse = Struct.new(:success, :username_to, :scope, :request_token, :redirect_url)
      RequestPermissionsFailureResponse = Struct.new(:success, :error_id, :error_msg)


      module_function

      def create_req_perm(callback)
        raise(ArgumentError, "callback is mandatory") unless DataTypes.none_empty?(callback)

        RequestPermissions.new(
          :request_permissions,
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

      def create_req_perm_response(username_to, scope, token, redirect_url)
        unless DataTypes.none_empty?(username_to, scope, token, redirect_url)
          raise(ArgumentError, "username_to, scope, token and redirect_url are all mandatory")
        end

        RequestPermissionsSuccessResponse.new(true, username_to, scope, token, redirect_url)
      end

      def create_failed_req_perm_response(error_id, error_msg)
        RequestPermissionsFailureResponse.new(false, error_id, error_msg)
      end
    end
  end
end
