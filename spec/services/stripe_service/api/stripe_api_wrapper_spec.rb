require 'spec_helper'

describe StripeService::API::StripeApiWrapper do
  describe '#verification_fields_needed' do
    let (:account_no_verification_needed) do
      OpenStruct.new(
        "verification": OpenStruct.new(
          "disabled_reason": nil,
          "due_by": nil,
          "fields_needed": ["legal_entity.verification.document"]
        )
      )
    end
    let (:account_last_name_needed) do
      OpenStruct.new(
        "verification": OpenStruct.new(
          "disabled_reason": "fields_needed",
          "due_by": 1522155600,
          "fields_needed": ["legal_entity.last_name"]
        )
      )
    end
    let (:account_verification_document_needed_1) do
      OpenStruct.new(
        "verification": OpenStruct.new(
          "disabled_reason": "fields_needed",
          "due_by": 1522155600,
          "fields_needed": ["legal_entity.verification.document"]
        )
      )
    end
    let (:account_verification_document_needed_2) do
      OpenStruct.new(
        "verification": OpenStruct.new(
          "disabled_reason": "fields_needed",
          "due_by": 1522155600,
          "fields_needed": ["legal_entity.personal_id_number", "legal_entity.verification.document"]
        )
      )
    end

    it 'is false for no verification' do
      result = StripeService::API::StripeApiWrapper.verification_fields_needed(account_no_verification_needed).any?
      expect(result).to eq false
    end

    it 'is false for last name' do
      result = StripeService::API::StripeApiWrapper.verification_fields_needed(account_last_name_needed).any?
      expect(result).to eq false
    end

    it 'is true for document' do
      result = StripeService::API::StripeApiWrapper.verification_fields_needed(account_verification_document_needed_1).any?
      expect(result).to eq true
    end

    it 'is return correct fields' do
      result = StripeService::API::StripeApiWrapper.verification_fields_needed(account_verification_document_needed_1)
      expect(result).to eq ["legal_entity.verification.document"]
      result = StripeService::API::StripeApiWrapper.verification_fields_needed(account_verification_document_needed_2)
      expect(result).to eq ["legal_entity.personal_id_number", "legal_entity.verification.document"]
      result = StripeService::API::StripeApiWrapper.verification_fields_needed(account_last_name_needed)
      expect(result).to eq []
      result = StripeService::API::StripeApiWrapper.verification_fields_needed(account_no_verification_needed)
      expect(result).to eq []
    end
  end
end
