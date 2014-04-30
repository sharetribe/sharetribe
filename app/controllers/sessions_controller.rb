require 'rest_client'

class SessionsController < ApplicationController

  skip_filter :check_email_confirmation
  skip_filter :dashboard_only
  skip_filter :single_community_only, :only => [ :create, :request_new_password ]
  skip_filter :cannot_access_without_joining, :only => [ :destroy, :confirmation_pending ]

  # For security purposes, Devise just authenticates an user
  # from the params hash if we explicitly allow it to. That's
  # why we need to call the before filter below.
  before_filter :allow_params_authentication!, :only => :create

  def new
    @selected_tribe_navi_tab = "members"
    @facebook_merge = session["devise.facebook_data"].present?
    if @facebook_merge
      @facebook_email = session["devise.facebook_data"]["email"]
      @facebook_name = "#{session["devise.facebook_data"]["given_name"]} #{session["devise.facebook_data"]["family_name"]}"
    end
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
    if @current_community
      person = authenticate_person!(:recall => "sessions#new")
    else
      person = authenticate_person!(:recall => "dashboard#login")
    end
    flash[:error] = nil
    @current_user = person

    # Store Facebook ID and picture if connecting with FB
    if session["devise.facebook_data"]
      @current_user.update_attribute(:facebook_id, session["devise.facebook_data"]["id"])
      # FIXME: Currently this doesn't work for very unknown reason. Paper clip seems to be processing, but no pic
      if @current_user.image_file_size.nil?
        @current_user.store_picture_from_facebook
      end
    end

    sign_in @current_user

    session[:form_login] = nil

    if @current_user
      @current_user.update_attribute(:active, true) unless @current_user.active?
    end

    unless @current_user && (!@current_user.communities.include?(@current_community) || @current_community.consent.eql?(@current_user.consent(@current_community)) || @current_user.is_admin?)
      # Either the user has succesfully logged in, but is not found in Sharetribe DB
      # or the user is a member of this community but the terms of use have changed.

      sign_out @current_user
      session[:temp_cookie] = "pending acceptance of new terms"
      session[:temp_person_id] =  @current_user.id
      session[:temp_community_id] = @current_community.id
      session[:consent_changed] = true if @current_user
      redirect_to terms_path and return
    end

    session[:person_id] = current_person.id

    if not @current_community
      redirect_to new_tribe_path
    elsif @current_user.communities.include?(@current_community) || @current_user.is_admin?
      flash[:notice] = t("layouts.notifications.login_successful", :person_name => view_context.link_to(@current_user.given_name_or_username, person_path(@current_user))).html_safe
      EventFeedEvent.create(:person1_id => @current_user.id, :community_id => @current_community.id, :category => "login") unless (@current_user.is_admin? && !@current_user.communities.include?(@current_community))
      if session[:return_to]
        redirect_to session[:return_to]
        session[:return_to] = nil
      elsif session[:return_to_content]
        redirect_to session[:return_to_content]
        session[:return_to_content] = nil
      else
        redirect_to root_path
      end
    else
      redirect_to new_tribe_membership_path
    end
  end

  def destroy
    sign_out
    session[:person_id] = nil
    flash[:notice] = t("layouts.notifications.logout_successful")
    redirect_to root
  end

  def index
    redirect_to login_path
  end

  def request_new_password
    if person = Person.find_by_email(params[:email])
      person.reset_password_token_if_needed
      PersonMailer.reset_password_instructions(person,params[:email], @current_community).deliver
      flash[:notice] = t("layouts.notifications.password_recovery_sent")
    else
      flash[:error] = t("layouts.notifications.email_not_found")
    end

    if on_dashboard?
      redirect_to dashboard_login_path
    else
      redirect_to login_path
    end
  end

  def facebook
    @person = Person.find_for_facebook_oauth(request.env["omniauth.auth"], @current_user)

    I18n.locale = exctract_locale_from_url(request.env['omniauth.origin']) if request.env['omniauth.origin']

    if @person
      flash[:notice] = t("devise.omniauth_callbacks.success", :kind => "Facebook")
      sign_in_and_redirect @person, :event => :authentication
    else
      data = request.env["omniauth.auth"].extra.raw_info

      if data.email.blank?
        flash[:error] = t("layouts.notifications.could_not_get_email_from_facebook")
        redirect_to sign_up_path and return
      end

      facebook_data = {"email" => data.email,
                       "given_name" => data.first_name,
                       "family_name" => data.last_name,
                       "username" => data.username,
                       "id"  => data.id}

      session["devise.facebook_data"] = facebook_data
      redirect_to :action => :create_facebook_based, :controller => :people
    end
  end

  #Facebook setup phase hook, that is used to dynamically set up a omniauth strategy for facebook on customer basis
  def facebook_setup
    request.env["omniauth.strategy"].options[:client_id] = @current_community.facebook_connect_id || APP_CONFIG.fb_connect_id
    request.env["omniauth.strategy"].options[:client_secret] = @current_community.facebook_connect_secret || APP_CONFIG.fb_connect_secret
    request.env["omniauth.strategy"].options[:iframe] = true
    request.env["omniauth.strategy"].options[:scope] = "offline_access,email"

    render :text => "Setup complete.", :status => 404 #This notifies the ominauth to continue
  end

  # Callback from Omniauth failures
  def failure
    I18n.locale = exctract_locale_from_url(request.env['omniauth.origin']) if request.env['omniauth.origin']
    error_message = params[:error_reason] || "login error"
    kind = env["omniauth.error.strategy"].name.to_s || "Facebook"
    flash[:error] = t("devise.omniauth_callbacks.failure",:kind => kind.humanize, :reason => error_message.humanize)
    redirect_to root
  end

  # This is used if user has not confirmed her email address
  def confirmation_pending

  end

end
