class SettingsController < ApplicationController

  before_action :except => :unsubscribe do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  before_action EnsureCanAccessPerson.new(:person_id, error_message_key: "layouts.notifications.you_are_not_authorized_to_view_this_content"), except: [:unsubscribe, :show]
  before_action EnsureCanAccessPerson.new(:person_id, allow_admin: true, error_message_key: "layouts.notifications.you_are_not_authorized_to_view_this_content"), only: :show

  def show
    @selected_left_navi_link = "profile"
    @service = Person::SettingsService.new(community: @current_community, params: params, current_user: @current_user)
    @service.add_location_to_person
    flash.now[:notice] = t("settings.profile.image_is_processing") if @service.image_is_processing?
  end

  def account
    target_user = Person.find_by!(username: params[:person_id], community_id: @current_community.id)
    @selected_left_navi_link = "account"
    target_user.emails.build
    has_unfinished = Transaction.unfinished_for_person(target_user).any?
    only_admin = @current_community.is_person_only_admin(target_user)

    render locals: {has_unfinished: has_unfinished, target_user: target_user, only_admin: only_admin}
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
        target_user.unsubscribe_from_community_updates
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

  def listings
    @selected_left_navi_link = "listings"
    @presenter = Listing::ListPresenter.new(@current_community, @current_user, params, false)
  end

  def transactions
    @selected_left_navi_link = "transactions"
    @service = Admin::TransactionsService.new(@current_community, params, request.format, @current_user, true)
    @transactions_presenter = Admin::TransactionsPresenter.new(params, @service)
  end

  private

  def find_person_to_unsubscribe(current_user, auth_token)
    current_user || Maybe(AuthToken.find_by_token(auth_token)).person.or_else { nil }
  end

end
