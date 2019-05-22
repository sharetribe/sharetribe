require 'rest_client'

class SessionsController < ApplicationController

  skip_before_action :cannot_access_if_banned, :only => [:destroy, :confirmation_pending]
  skip_before_action :cannot_access_without_confirmation, :only => [:destroy, :confirmation_pending]
  skip_before_action :ensure_consent_given, only: [:destroy, :confirmation_pending]
  skip_before_action :ensure_user_belongs_to_community, :only => [:destroy, :confirmation_pending]

  # For security purposes, Devise just authenticates an user
  # from the params hash if we explicitly allow it to. That's
  # why we need to call the before filter below.
  before_action :allow_params_authentication!, :only => :create

  def new
    if params[:return_to].present?
      session[:return_to] = params[:return_to]
    end

    @selected_tribe_navi_tab = "members"
  end

  def create
    session[:form_login] = params[:person][:login]

    # Start a session with Devise

    # In case of failure, set the message already here and
    # clear it afterwards, if authentication worked.
    flash.now[:error] = t("layouts.notifications.login_failed")

    # Since the authentication happens in the rack layer,
    # we need to tell Devise to call the action "sessions#new"
    # in case something goes bad.
    person = authenticate_person!(:recall => "sessions#new")
    @current_user = person

    flash[:error] = nil

    sign_in @current_user

    setup_intercom_user

    session[:form_login] = nil

    unless @current_user.is_admin? || terms_accepted?(@current_user, @current_community)
      sign_out @current_user
      session[:temp_cookie] = "pending acceptance of new terms"
      session[:temp_person_id] =  @current_user.id
      session[:temp_community_id] = @current_community.id
      session[:consent_changed] = true if @current_user
      redirect_to terms_path and return
    end

    login_successful = t("layouts.notifications.login_successful", person_name: view_context.link_to(PersonViewUtils.person_display_name_for_type(@current_user, "first_name_only"), person_path(@current_user)))
    visit_admin = t('layouts.notifications.visit_admin', link: view_context.link_to(t('layouts.notifications.visit_admin_link'), admin_details_edit_path))
    flash[:notice] = "#{login_successful}#{@current_user.has_admin_rights?(@current_community) ? " #{visit_admin}" : ''}".html_safe
    if session[:return_to]
      redirect_to session[:return_to]
      session[:return_to] = nil
    elsif session[:return_to_content]
      redirect_to session[:return_to_content]
      session[:return_to_content] = nil
    else
      redirect_to search_path
    end
  end

  def destroy
    logged_out_user = @current_user
    sign_out

    # Admin Intercom shutdown
    IntercomHelper::ShutdownHelper.intercom_shutdown(session, cookies, request.host_with_port)

    flash[:notice] = t("layouts.notifications.logout_successful")
    mark_logged_out(flash, logged_out_user)
    redirect_to landing_page_path
  end

  def index
    redirect_to login_path
  end

  def request_new_password
    person =
      Person
      .joins("LEFT OUTER JOIN emails ON emails.person_id = people.id")
      .where("emails.address = :email AND (people.is_admin = '1' OR people.community_id = :cid)", email: params[:email], cid: @current_community.id)
      .first
    if person
      token = person.reset_password_token_if_needed
      MailCarrier.deliver_later(PersonMailer.reset_password_instructions(person, params[:email], token, @current_community))
      flash[:notice] = t("layouts.notifications.password_recovery_sent")
    else
      flash[:error] = t("layouts.notifications.email_not_found")
    end

    redirect_to login_path
  end

  def passthru
    render status: :not_found, plain: "Not found. Authentication passthru."
  end
  private

  def terms_accepted?(user, community)
    user && community.consent.eql?(user.consent)
  end
end
