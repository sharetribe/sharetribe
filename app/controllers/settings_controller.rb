class SettingsController < ApplicationController

  before_action :except => :unsubscribe do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  before_action EnsureCanAccessPerson.new(:person_id, error_message_key: "layouts.notifications.you_are_not_authorized_to_view_this_content"), except: :unsubscribe

  def show
    target_user = Person.find_by!(username: params[:person_id], community_id: @current_community.id)
    add_location_to_person!(target_user)
    flash.now[:notice] = t("settings.profile.image_is_processing") if target_user.image.processing?
    @selected_left_navi_link = "profile"
    render locals: {target_user: target_user}
  end

  def account
    target_user = Person.find_by!(username: params[:person_id], community_id: @current_community.id)
    @selected_left_navi_link = "account"
    target_user.emails.build
    has_unfinished = TransactionService::Transaction.has_unfinished_transactions(target_user.id)

    render locals: {has_unfinished: has_unfinished, target_user: target_user}
  end

  def notifications
    target_user = Person.find_by!(username: params[:person_id], community_id: @current_community.id)
    @selected_left_navi_link = "notifications"
    render locals: {target_user: target_user}
  end

  def unsubscribe
    target_user = find_person_to_unsubscribe(@current_user, params[:auth])

    if target_user && target_user.username == params[:person_id] && params[:email_type].present?
      if params[:email_type] == "community_updates"
        MarketplaceService::Person::Command.unsubscribe_person_from_community_updates(target_user.id)
      elsif [Person::EMAIL_NOTIFICATION_TYPES, Person::EMAIL_NEWSLETTER_TYPES].flatten.include?(params[:email_type])
        target_user.preferences[params[:email_type]] = false
        target_user.save!
      else
        render :unsubscribe, :status => :bad_request, locals: {target_user: target_user, unsubscribe_successful: false} and return
      end
      render :unsubscribe, locals: {target_user: target_user, unsubscribe_successful: true}
    else
      render :unsubscribe, :status => :unauthorized, locals: {target_user: target_user, unsubscribe_successful: false}
    end
  end

  def toggle_payment
    if params[:no_stripe].present?
      @current_user.preferences[:no_stripe] = params[:no_stripe] == 'true'
      @current_user.save
    end
    if params[:no_paypal].present?
      @current_user.preferences[:no_paypal] = params[:no_paypal] == 'true'
      @current_user.save
    end
    render body: "OK"
  end

  private

  def add_location_to_person!(person)
    unless person.location
      person.build_location(:address => person.street_address)
      person.location.search_and_fill_latlng
    end
    person
  end

  def find_person_to_unsubscribe(current_user, auth_token)
    current_user || Maybe(AuthToken.find_by_token(auth_token)).person.or_else { nil }
  end

end
