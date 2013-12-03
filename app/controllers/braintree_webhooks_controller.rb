class BraintreeWebhooksController < ApplicationController

  skip_before_filter :verify_authenticity_token
  skip_filter :check_email_confirmation, :dashboard_only

  before_filter do
    unless @current_community.braintree_in_use?
      # Log here?
      render :nothing => true, :status => 400 and return
    end
  end

  # This module contains all the handlers per notification kind.
  # Method name MUST match to the notification kind
  module Handlers
    class << self
      def sub_merchant_account_approved(notification)
        person_id = notification.merchant_account.id
        braintree_account = BraintreeAccount.find_by_person_id(person_id)
        braintree_account.update_attributes(:status => "active")

        person = Person.find_by_id(person_id)

        PersonMailer.braintree_account_approved(person, @current_community).deliver
      end

      def sub_merchant_account_declined(notification)
        person_id = notification.merchant_account.id
        braintree_account = BraintreeAccount.find_by_person_id(person_id)
        braintree_account.update_attributes(:status => "suspended")
      end
    end
  end

  # Actions
  def challenge
    challenge_response = BraintreeService.webhook_notification_verify(@current_community, params[:bt_challenge])

    # TODO if fail/success?

    render :text => challenge_response, :status => 200
  end

  def hooks
    begin
      parsed_response = BraintreeService.webhook_notification_parse(@current_community, params[:bt_signature], params[:bt_payload])
    rescue Braintree::BraintreeError => bt_e
      # Log here?
      render :nothing => true, :status => 400 and return
      return
    end

    kind = parsed_response.kind.to_sym
    search_privates = true

    if Handlers.respond_to?(kind, search_privates)
      Handlers.send(kind, parsed_response)
    else
      # Logging here?
    end

    render :nothing => true
  end
end