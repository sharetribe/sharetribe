class BraintreeWebhooksController < ApplicationController

  skip_before_filter :verify_authenticity_token
  skip_filter :fetch_community, :check_email_confirmation, :dashboard_only

  before_filter :fetch_community_by_params

  before_filter do
    unless @current_community.braintree_in_use?
      BTLog.error("Received webhook notification even though '#{@current_community.domain}' does not have Braintree in use")
      render :nothing => true, :status => 400 and return
    end
  end

  # This module contains all the handlers per notification kind.
  # Method name MUST match to the notification kind
  module Handlers
    class << self
      def sub_merchant_account_approved(notification, community)
        person_id = notification.merchant_account.id
        BTLog.warn("Approved submerchant account for person #{person_id}")

        braintree_account = BraintreeAccount.find_by_person_id(person_id)
        braintree_account.update_attributes(:status => "active")

        person = Person.find_by_id(person_id)

        PersonMailer.braintree_account_approved(person, community).deliver
      end

      def sub_merchant_account_declined(notification, community)
        person_id = notification.merchant_account.id
        BTLog.warn("Declined submerchant account for person #{person_id}")

        braintree_account = BraintreeAccount.find_by_person_id(person_id)
        braintree_account.update_attributes(:status => "suspended")
      end

      def transaction_disbursed(notification, community)
        transaction = notification.transaction
        BTLog.warn("Transaction #{transaction.id} disbursed")

        payment = Payment.find_by_braintree_transaction_id(transaction.id)
        payment.disbursed!
      end
    end
  end

  # Actions
  def challenge
    begin
      challenge_response = BraintreeApi.webhook_notification_verify(@current_community, params[:bt_challenge])
    rescue Braintree::BraintreeError => bt_e
      BTLog.error("Error while parsing challenge: #{bt_e.inspect}")
      render :nothing => true, :status => 400 and return
    end

    render :text => challenge_response, :status => 200
  end

  def hooks
    begin
      parsed_response = BraintreeApi.webhook_notification_parse(@current_community, params[:bt_signature], params[:bt_payload])
    rescue Braintree::BraintreeError => bt_e
      BTLog.error("Error while parsing webhook notification: #{bt_e.inspect}")
      render :nothing => true, :status => 400 and return
    end

    kind = parsed_response.kind.to_sym
    search_privates = true

    if Handlers.respond_to?(kind, search_privates)
      Handlers.send(kind, parsed_response, @current_community)
    else
      BTLog.warn("Received unimplemented webhook notification #{kind}: #{parsed_response.inspect}")
    end

    render :nothing => true
  end

  private

  # Instead of fetching community by host (http://community.sharetribe.com),
  # this filter fetched community by `community_id` parameter
  # (http://sharetribe.com?community_id=id)
  def fetch_community_by_params
    fetch_community_by_strategy {
      Community.find_by_id(params[:community_id])
    }
  end
end
