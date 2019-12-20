# rubocop:disable Style/MixinUsage
include ApplicationHelper
include ListingsHelper
include TruncateHtmlHelper
# rubocop:enable Style/MixinUsage

class CommunityMailer < ActionMailer::Base
  helper :markdown

  include MailUtils

  require "truncate_html"

  # This task is expected to be run with daily or hourly scheduling
  # It looks through all users and send email to those who want it now
  def self.deliver_community_updates
    Person.find_each do |person|
      next unless person.should_receive_community_updates_now?

      community = person.accepted_community
      next unless community

      listings_to_send = community.get_new_listings_to_update_email(person) if community.automatic_newsletters
      next if listings_to_send.blank?

      begin
        ApplicationHelper.store_community_service_name_to_thread_from_community(community)
        token = AuthToken.create_unsubscribe_token(person_id: person.id).token
        MailCarrier.deliver_now(
          CommunityMailer.community_updates(
          recipient: person,
          community: community,
          listings: listings_to_send,
          unsubscribe_token: token
        ))
      rescue StandardError => e
        # Catch the exception and continue sending emails
        puts "Error sending mail to #{person.confirmed_notification_emails} community updates: #{e.message}"
        ApplicationHelper.send_error_notification("Error sending mail to #{person.confirmed_notification_emails} community updates: #{e.message}", e.class)
      end
      # After sending updates for all communities that had something new, update the time of last sent updates to Time.now.
      person.update_attribute(:community_updates_last_sent_at, Time.now)
    end
  end

  def community_updates(recipient:, community:, listings:, unsubscribe_token:)
    @community = community
    @current_community = community
    @recipient = recipient
    @listings = listings

    unless @recipient.member_of?(@community)
      logger.info "Trying to send community updates to a person who is not member of the given community. Skipping."
      return
    end

    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do

      @number_of_days = time_difference_in_days(@recipient.last_community_updates_at)
      @time_since_last_update = t("timestamps.days_since",
                                  :count => @number_of_days)
      @url_params = build_url_params(@community, @recipient, "weeklymail")

      @show_listing_shape_label = community.shapes.count > 1
      @show_branding_info = !PlanService::API::Api.plans.get_current(community_id: community.id).data[:features][:whitelabel]

      @title_link_text = t("emails.community_updates.title_link_text",
                           :community_name => @community.full_name(@recipient.locale))
      subject = t("emails.community_updates.update_mail_title", :title_link => @title_link_text)

      delivery_method = APP_CONFIG.mail_delivery_method.to_sym unless Rails.env.test?

      mail(:to => @recipient.confirmed_notification_emails_to,
           :from => community_specific_sender(community),
           :subject => subject,
           :delivery_method => delivery_method) do |format|
             format.html { render v2_template(community.id, 'community_updates'), layout: v2_layout(community.id, 'email_blank_layout'),locals: { unsubscribe_token: unsubscribe_token } }
      end
    end
  end

  private

  def time_difference_in_days(from_time, to_time = Time.now)
    return 1 if from_time.nil?

    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs/60)/1440.0).round
  end

  def premailer_mail(opts, &block)
    premailer(mail(opts, &block))
  end
end
