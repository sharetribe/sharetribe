require 'spec_helper'

describe ListingShapeProcessViewUtils::ShapeSanitizer do

    def expect_success(shape, process_summary)
      res = ListingShapeProcessViewUtils::ShapeSanitizer.validate(shape, process_summary, @validators)
      expect(res.success).to eq true
    end

    def expect_error(shape, process_summary, error_code)
      res = ListingShapeProcessViewUtils::ShapeSanitizer.validate(shape, process_summary, @validators)
      expect(res.success).to eq false
      expect(res.data[:code]).to eq error_code
    end

    def test_validators!(*validators)
      @validators = validators
    end

    describe "#validate" do
      Sanitizer = ListingShapeProcessViewUtils::ShapeSanitizer # easier to reference the validators

      it "price must be enabled if online payments is in use" do
        test_validators!(Sanitizer::PRICE_ENABLED_IF_ONLINE_PAYMENTS)

        # none
        expect_success({ price_enabled: false , transaction_process: {process: :none}}, [])
        expect_success({ price_enabled: true , transaction_process: {process: :none}}, [])

        # preauth
        expect_success({ price_enabled: true , transaction_process: {process: :preauthorize}}, [])
        expect_error({ price_enabled: false , transaction_process: {process: :preauthorize}}, [], "price_enabled_if_payments")

        # postpay
        expect_success({ price_enabled: true , transaction_process: {process: :postpay}}, [])
        expect_error({ price_enabled: false , transaction_process: {process: :postpay}}, [], "price_enabled_if_payments")
      end

      it "preauthorize must be used if shipping" do
        test_validators!(Sanitizer::PREAUTHORIZE_IF_SHIPPING)

        # none
        expect_success({ shipping_enabled: false, transaction_process: {process: :none}}, [])
        expect_error({ shipping_enabled: true, transaction_process: {process: :none}}, [], "preauthorize_enabled_if_shipping")

        # preauth
        expect_success({ shipping_enabled: false, transaction_process: {process: :preauthorize}}, [])
        expect_success({ shipping_enabled: true, transaction_process: {process: :preauthorize}}, [])

        # postpay
        expect_success({ shipping_enabled: false, transaction_process: {process: :postpay}}, [])
        expect_error({ shipping_enabled: true, transaction_process: {process: :postpay}}, [], "preauthorize_enabled_if_shipping")
      end

      it "price must be enabled if there are any units defined" do
        test_validators!(Sanitizer::PRICE_ENABLED_IF_UNITS)

        # no units
        expect_success({ price_enabled: false, units: []}, [])
        expect_success({ price_enabled: true, units: []}, [])

        # with units
        expect_error({ price_enabled: false, units: [type: :day]}, [], "price_enabled_if_units")
        expect_success({ price_enabled: true, units: [type: :day]}, [])
      end

      it "price must be disabled if author is not the seller" do
        test_validators!(Sanitizer::PRICE_DISABLED_IF_AUTHOR_IS_NOT_SELLER)

        # author is seller
        expect_success({price_enabled: false, transaction_process: {author_is_seller: true}}, [])
        expect_success({price_enabled: true, transaction_process: {author_is_seller: true}}, [])

        # author is not seller
        expect_success({price_enabled: false, transaction_process: {author_is_seller: false}}, [])
        expect_error({price_enabled: true, transaction_process: {author_is_seller: false}}, [], "price_disabled_if_author_is_not_seller")
      end

      it "process must be none if author is not seller" do
        test_validators!(Sanitizer::PROCESS_MUST_BE_NONE_IF_AUTHOR_IS_NOT_SELLER)

        # author is not seller
        expect_success( {transaction_process: {process: :none, author_is_seller: false }}, [])
        expect_error( {transaction_process: {process: :preauthorize, author_is_seller: false }}, [], "process_none_if_author_is_not_seller")
        expect_error( {transaction_process: {process: :postpay, author_is_seller: false }}, [], "process_none_if_author_is_not_seller")

        # author is seller
        expect_success( {transaction_process: {process: :none, author_is_seller: true }}, [])
        expect_success( {transaction_process: {process: :preauthorize, author_is_seller: true }}, [])
        expect_success( {transaction_process: {process: :postpay, author_is_seller: true }}, [])
      end

      it "suitable process available" do
        test_validators!(Sanitizer::PROCESS_AVAILABLE)

        # author is seller, only
        expect_success({transaction_process: { author_is_seller: false}}, [{process: :none, author_is_seller: false}])
        expect_error({transaction_process: { author_is_seller: false}}, [{author_is_seller: true}], "suitable_process_not_available")

        # none
        expect_success({transaction_process: { process: :none, author_is_seller: false}}, [{process: :none, author_is_seller: false}])
        expect_error({transaction_process: { process: :none, author_is_seller: false}}, [{process: :none, author_is_seller: true}], "suitable_process_not_available")
        expect_error({transaction_process: { process: :none, author_is_seller: true}}, [{process: :none, author_is_seller: false}], "suitable_process_not_available")
        expect_success({transaction_process: { process: :none, author_is_seller: true}}, [{process: :none, author_is_seller: true}])

        # preauthorize
        expect_success({transaction_process: { process: :preauthorize, author_is_seller: true}}, [{process: :preauthorize, author_is_seller: true}])
        expect_error({transaction_process: { process: :preauthorize, author_is_seller: true}}, [{process: :none, author_is_seller: true}], "suitable_process_not_available")

        # postpay
        expect_success({transaction_process: { process: :postpay, author_is_seller: true}}, [{process: :postpay, author_is_seller: true}])
        expect_error({transaction_process: { process: :postpay, author_is_seller: true}}, [{process: :preauthorize, author_is_seller: true}], "suitable_process_not_available")
      end
    end

end
