class PeopleController < ApplicationController
  include UrlHelper
  protect_from_forgery :except => :create
  
  before_filter :only => [ :update, :update_avatar ] do |controller|
    controller.ensure_authorized "you_are_not_authorized_to_view_this_content"
  end
  
  before_filter :person_belongs_to_current_community, :only => :show
  before_filter :ensure_is_admin, :only => [ :activate, :deactivate ]
  
  helper_method :show_closed?
  
  def index
    # this is not yet in use in this version of Kassi, but old URLs point here so implement this to avoid errors
   render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404
  end
  
  def show
    @community_membership = CommunityMembership.find_by_person_id_and_community_id(@person.id, @current_community.id)
    @listings = params[:type] && params[:type].eql?("requests") ? @person.requests : @person.offers
    @listings = show_closed? ? @listings : @listings.open 
    @listings = @listings.visible_to(@current_user, @current_community).order("open DESC, id DESC").paginate(:per_page => 15, :page => params[:page])
    render :partial => "listings/additional_listings" if request.xhr?
  end

  def new
    @person = Person.new
  end

  def create
    # if the request came from different domain, redirects back there.
    # e.g. if using login-subdoain for registering in with https    
    if params["community"].blank?
      ApplicationHelper.send_error_notification("Got login request, but origin community is blank! Can't redirect back.", "Errors that should never happen")
    end
    domain = "http://#{with_subdomain(params[:community])}"
    
    if @current_community.join_with_invite_only
      # Check if invitation is valid
      unless Invitation.code_usable?(params[:invitation_code], @current_community)
        # abort user creation if invitation is not usable. (This actually should not happen since the code is checked with javascript)
        ApplicationHelper.send_error_notification("Invitation code check did not prevent submiting form, but was detected in the controller", "Invitation code error")
        # TODO: if this ever happens, should change the message to something else than "unknown error"
        flash[:error] = :unknown_error
        redirect_to domain + sign_up_path and return
      else
        invitation = Invitation.find_by_code(params[:invitation_code].upcase)
      end
    end
    
    @person = Person.new
    if APP_CONFIG.use_recaptcha && @current_community.use_captcha && !verify_recaptcha_unless_already_accepted(:model => @person, :message => t('people.new.captcha_incorrect'))
        
      # This should not actually ever happen if all the checks work at Kassi's end.
      # Anyway if Captha responses with error, show message to user
      # Also notify admins that this kind of error happened.
      # TODO: if this ever happens, should change the message to something else than "unknown error"
      flash[:error] = :unknown_error
      ApplicationHelper.send_error_notification("New user Sign up failed because Captha check failed, when it shouldn't.", "Captcha error")
      redirect_to domain + sign_up_path and return
    end

    # Open an ASI Session first only for Kassi to be able to create a user
    @session = Session.create
    session[:cookie] = @session.cookie
    params[:person][:locale] =  params[:locale] || APP_CONFIG.default_locale
    params[:person][:test_group_number] = 1 + rand(4)
    
    # skip email confirmation unless it's required in this community
    params[:person][:confirmed_at] =  (@current_community.email_confirmation ? nil : Time.now)
    
    # Try to create a new person in ASI.
    begin
      @person = Person.create(params[:person], session[:cookie], @current_community.use_asi_welcome_mail?)
      @person.set_default_preferences
      # Make person a member of the current community
      membership = CommunityMembership.new(:person => @person, :community => @current_community, :consent => @current_community.consent)
      membership.invitation = invitation if invitation.present?
      membership.save!
    rescue RestClient::RequestFailed => e
      logger.info "Person create failed because of #{JSON.parse(e.response.body)["messages"]}"
      # This should not actually ever happen if all the checks work at Kassi's end.
      # Anyway if ASI responses with error, show message to user
      # Now it's unknown error, since picking the message from ASI and putting it visible without translation didn't work for some reason.
      # Also notify admins that this kind of error happened.
      flash[:error] = :unknown_error
      ApplicationHelper.send_error_notification("New user Sign up failed because ASI returned: #{JSON.parse(e.response.body)["messages"]}", "Signup error")
      redirect_to domain + sign_up_path and return
    end
    session[:person_id] = @person.id
    flash[:notice] = [:login_successful, (@person.given_name_or_username + "!").to_s, person_path(@person)]
    
    # If invite was used, reduce usages left
    invitation.use_once! if invitation.present?
    
    PersonMailer.new_member_notification(@person, params[:community], params[:person][:email]).deliver if @current_community.email_admins_about_new_members
    
    if @current_community.email_confirmation
      flash[:notice] = "account_creation_succesful_you_still_need_to_confirm_your_email"
      redirect_to :controller => "sessions", :action => "confirmation_pending"
    else
      redirect_to(session[:return_to].present? ? domain + session[:return_to]: domain + root_path)
    end
  end
  
  def update
	  if params[:person] && params[:person][:location] && (params[:person][:location][:address].empty?) || (params[:person][:street_address].blank? || params[:person][:street_address].empty?)
      params[:person].delete("location")
      if @person.location
        @person.location.delete
      end
	  end
    begin
      @person.update_attributes(params[:person], session[:cookie])
      flash[:notice] = :person_updated_successfully
    rescue RestClient::RequestFailed => e
      flash[:error] = "update_error"
    end
    redirect_to :back
  end
  
  def update_avatar
    if params[:file] && @person.update_avatar(params[:file], session[:cookie])
      flash[:notice] = :avatar_upload_successful
    else 
      flash[:error] = :avatar_upload_failed
    end
    redirect_to avatar_person_settings_path(:person_id => @current_user.id.to_s)  
  end
  
  def check_username_availability
    respond_to do |format|
      format.json { render :json => Person.username_available?(params[:person][:username]) }
    end
  end
  
  def check_email_availability
    available = true
    
    #first check if the community allows this email
    if @current_community.allowed_emails.present?
      available = email_allowed?(params[:person][:email], @current_community)
    end
    
    
    if available
      # Then check if it's already in use
      if @current_user && (@current_user.email == params[:person][:email])
        # Current user's own email should not be shown as unavailable
        available = true
      else
        available = Person.email_available?(params[:person][:email])
      end
    end
    
    respond_to do |format|
      format.json { render :json => available }
    end
  end
  
  def check_invitation_code
    respond_to do |format|
      format.json { render :json => Invitation.code_usable?(params[:invitation_code], @current_community) }
    end
  end
  
  
  def show_closed?
    params[:closed] && params[:closed].eql?("true")
  end

  def check_captcha
    if verify_recaptcha_unless_already_accepted
      render :json => "success" and return
    else
      render :json => "failed" and return
    end
  end
  
  # Showed when somebody tries to view a profile of
  # a person that is not a member of that community
  def not_member
  end

  def activate
    change_active_status("activated")
  end
  
  def deactivate
    change_active_status("deactivated")
  end

  private
  
  def verify_recaptcha_unless_already_accepted(options={})
    # Check if this captcha is already accepted, because ReCAPTCHA API will return false for further queries
    if session[:last_accepted_captha] == "#{params["recaptcha_challenge_field"]}#{params["recaptcha_response_field"]}"
      return true
    else
      accepted = verify_recaptcha(options)
      if accepted
        session[:last_accepted_captha] = "#{params["recaptcha_challenge_field"]}#{params["recaptcha_response_field"]}"
      end
      return accepted
    end
  end
  
  
  def change_active_status(status)
    @person = Person.find(params[:id])
    #@person.update_attribute(:active, 0)
    @person.update_attribute(:active, (status.eql?("activated") ? true : false))
    @person.listings.update_all(:open => false) if status.eql?("deactivated") 
    notice = "person_#{status}"
    respond_to do |format|
      format.html { 
        flash[:notice] = notice
        redirect_to @person
      }
      format.js {
        flash.now[:notice] = notice
        render :layout => false 
      }
    end
  end
  
  def email_allowed?(email, community)
    allowed = false
    allowed_array = community.allowed_emails.split(",")
    
    allowed_array.each do |allowed_domain_or_address|
      allowed_domain_or_address.strip!
      allowed_domain_or_address.gsub!('.', '\.') #change . to be \. to only match a dot, not any char
      if email =~ /#{allowed_domain_or_address}$/
        allowed = true
        break
      end
    end
    
    return allowed
  end
  
end
