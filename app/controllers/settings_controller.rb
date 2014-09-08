class SettingsController < ApplicationController

  before_filter :except => :unsubscribe do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  before_filter :except => :unsubscribe do |controller|
    controller.ensure_authorized t("layouts.notifications.you_are_not_authorized_to_view_this_content")
  end

  skip_filter :dashboard_only

  def show
    @selected_left_navi_link = "profile"
    add_location_to_person
    render :action => :profile
  end

  def profile
    @selected_left_navi_link = "profile"
    # This is needed if person doesn't yet have a location
    # Build a new one based on old street address or then empty one.
    add_location_to_person
  end

  def account
    @selected_left_navi_link = "account"
    @person.emails.build
  end

  def notifications
    @selected_left_navi_link = "notifications"
  end

  def payments
    @selected_left_navi_link = "payments"
  end

  def unsubscribe
    @person_to_unsubscribe = find_person_to_unsubscribe(@current_user, params[:auth])

    if @person_to_unsubscribe && @person_to_unsubscribe.username == params[:person_id] && params[:email_type].present?
      if params[:email_type] == "community_updates"
        MarketplaceService::Person::Command.unsubscribe_person_from_community_updates(@person_to_unsubscribe.id)
      elsif [Person::EMAIL_NOTIFICATION_TYPES, Person::EMAIL_NEWSLETTER_TYPES].flatten.include?(params[:email_type])
        @person_to_unsubscribe.preferences[params[:email_type]] = false
        @person_to_unsubscribe.save!
      else
        @unsubscribe_successful = false
        render :unsubscribe, :status => :bad_request and return
      end
      @unsubscribe_successful = true
      render :unsubscribe
    else
      @unsubscribe_successful = false
      render :unsubscribe, :status => :unauthorized
    end
  end

  private

  def add_location_to_person
    unless @person.location
      @person.build_location(:address => @person.street_address,:location_type => 'person')
      @person.location.search_and_fill_latlng
    end
  end

  def find_person_to_unsubscribe(current_user, auth_token)
    current_user || Maybe(AuthToken.find_by_token(auth_token)).person.or_else { nil }
  end

end
