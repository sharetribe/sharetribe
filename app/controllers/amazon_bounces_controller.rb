class AmazonBouncesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :notification
  skip_filter :fetch_community, :check_email_confirmation, :dashboard_only

  before_filter :check_sns_token

  def notification
    amz_message_type = request.headers['x-amz-sns-message-type']

    if amz_message_type.to_s.downcase == 'subscriptionconfirmation'
      send_subscription_confirmation request.raw_post
      render :nothing => true and return
    end

    if amz_message_type.to_s.downcase == 'notification'
      msg = JSON.parse(request.raw_post)
      # Sometimes amazon sends notifications more wrapped than other times
      msg = JSON.load(msg['Message']) unless msg['Message'].nil?
      type = msg['notificationType']

      if type == 'Bounce'
        handle_bounces(msg)
      elsif type == 'Complaint'
        handle_complaints(msg)
      else
        logger.warn "\nUnrecognized message from Amazon SNS notification center:"
        logger.warn msg.to_s
      end
    end
    render :nothing => true
  end

  private

  def send_subscription_confirmation(request_body)
    require 'open-uri'
    json = JSON.parse(request_body)
    subscribe_url = json['SubscribeURL']
    open(subscribe_url)
  end

  def handle_bounces(msg)
    bounce = msg['bounce']
    bounce_recipients = bounce['bouncedRecipients']
    bounce_recipients.each do |recipient|
      MarketplaceService::Person::Command.unsubscribe_email_from_community_updates(recipient['emailAddress'])
    end
  end


  def handle_complaints(msg)
    complaint = msg['complaint']
    complaint_recipients = complaint['complainedRecipients']
    complaint_recipients.each do |recipient|
      MarketplaceService::Person::Command.unsubscribe_email_from_community_updates(recipient['emailAddress'])
    end
    unless complaint['complaintFeedbackType'].nil?
      logger.info "\nComplaint with feedback from Amazon SNS notification center:"
      logger.info msg.to_s
    end
  end

  def check_sns_token
    if APP_CONFIG.sns_notification_token != params['sns_notification_token']
      return render :nothing => true
    end
  end

end