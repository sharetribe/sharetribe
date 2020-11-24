module PaypalService

  class Onboarding

    OnboardingParameters = EntityUtils.define_builder(
      [:partnerId, :mandatory, :string],
      [:returnToPartnerUrl, :mandatory, :string],
      [:merchantId, transform_with: -> (_) { SecureRandom.uuid }],
      [:partnerLogoUrl, :string],
      [:countryCode, :string],
      [:productIntentID, const_value: "addipmt"],
      [:integrationType, const_value: "T"],
      [:permissionNeeded, const_value: "EXPRESS_CHECKOUT,REFUND,AUTH_CAPTURE,TRANSACTION_DETAILS,REFERENCE_TRANSACTION,ACCESS_BASIC_PERSONAL_DATA"],
      [:displayMode, const_value: "Regular"],
      [:showPermissions, const_value: "TRUE"])

    OnboardingValidation = EntityUtils.define_builder(
      [:success, :mandatory, :to_bool],
      [:permissions_granted, :mandatory, :to_bool],
      [:onboarding_id, :mandatory, :string],
      [:paypal_merchant_id, :mandatory, :string],
      [:account_status, :string],
      [:is_email_confirmed, :to_bool],
      [:return_msg, :string])

    def initialize(config)
      @config = config
    end

    def create_onboarding_link(opts)
      params = OnboardingParameters.call(opts.merge({partnerId: @config[:api_credentials][:partner_id]}))
      params.merge({ redirect_url: URLUtils.build_url(base_path(@config[:endpoint]), params) })
    end

    def validate_result_params(onboarding_params)
      if onboarding_params["merchantId"].present? && onboarding_params["merchantIdInPayPal"].present? && onboarding_params["permissionsGranted"].downcase == "true"
        OnboardingValidation.call({
          success: true,
          permissions_granted: true,
          onboarding_id: onboarding_params["merchantId"],
          paypal_merchant_id: onboarding_params["merchantIdInPayPal"],
          account_status: onboarding_params["accountStatus"],
          is_email_confirmed: onboarding_params["isEmailConfirmed"],
          return_msg: onboarding_params["returnMessage"]})
      else
        {success: false}
      end
    end


    private

    def base_path(endpoint)
      if endpoint[:endpoint_name] == "sandbox"
        "https://www.sandbox.paypal.com/webapps/merchantboarding/webflow/externalpartnerflow"
      else
        raise ArgumentError.new("Unknown endpoint type: #{endpoint}")
      end
    end

  end
end
