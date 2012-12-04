class PeopleController < Devise::RegistrationsController
  
  include UrlHelper, PeopleHelper
  
  layout :choose_layout
  
  
  skip_before_filter :verify_authenticity_token, :only => [:creates]
  
  before_filter :only => [ :update, :update_avatar ] do |controller|
    controller.ensure_authorized "you_are_not_authorized_to_view_this_content"
  end
  
  before_filter :person_belongs_to_current_community, :only => :show
  before_filter :ensure_is_admin, :only => [ :activate, :deactivate ]
  
  skip_filter :check_email_confirmation, :only => [ :update]
  skip_filter :dashboard_only
  skip_filter :single_community_only, :only => [ :create, :update, :check_username_availability, :check_email_availability, :check_email_availability_and_validity, :check_email_availability_for_new_tribe]
  skip_filter :not_public_in_private_community, :only => [ :new, :create, :check_username_availability, :check_email_availability_and_validity, :check_email_availability, :check_email_availability_for_new_tribe, :check_invitation_code]
  skip_filter :cannot_access_without_joining, :only => [ :check_email_validity, :check_invitation_code ]
  
  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_filter :verify_authenticity_token, :only => [:activate, :deactivate]
  
  
  helper_method :show_closed?
  
  def index
    # this is not yet in use in this version of Sharetribe, but old URLs point here so implement this to avoid errors
   render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
  end
  
  def show
    @community_membership = CommunityMembership.find_by_person_id_and_community_id(@person.id, @current_community.id)
    @listings = params[:type] && params[:type].eql?("requests") ? @person.requests : @person.offers
    @listings = show_closed? ? @listings : @listings.currently_open 
    @listings = @listings.visible_to(@current_user, @current_community).order("open DESC, id DESC").paginate(:per_page => 15, :page => params[:page])
    render :partial => "listings/additional_listings" if request.xhr?
  end

  def new
    redirect_to root if logged_in?
    @person = Person.new
    @container_class = params[:private_community] ? "container_12" : "container_24"
    @grid_class = params[:private_community] ? "grid_6 prefix_3 suffix_3" : "grid_10 prefix_7 suffix_7"
  end

  def create
    @current_community ? domain = "http://#{with_subdomain(params[:community])}" : domain = "#{request.protocol}#{request.host_with_port}"
    error_redirect_path = domain + sign_up_path
    
    if params[:person][:email_confirmation].present? # Honey pot for spammerbots
      flash[:error] = :registration_considered_spam
      ApplicationHelper.send_error_notification("Registration Honey Pot is hit.", "Honey pot")
      redirect_to error_redirect_path and return
    end
    
    if @current_community && @current_community.join_with_invite_only? || params[:invitation_code]

      unless Invitation.code_usable?(params[:invitation_code], @current_community)
        # abort user creation if invitation is not usable. 
        # (This actually should not happen since the code is checked with javascript)
        ApplicationHelper.send_error_notification("Invitation code check did not prevent submiting form, but was detected in the controller", "Invitation code error")
        
        # TODO: if this ever happens, should change the message to something else than "unknown error"
        flash[:error] = :unknown_error
        redirect_to error_redirect_path and return
      else
        invitation = Invitation.find_by_code(params[:invitation_code].upcase)
      end
    end
    
    # Check that email is not taken
    unless Person.email_available?(params[:person][:email])
      flash[:error] = t("people.new.email_is_in_use")
      redirect_to error_redirect_path and return
    end
    
    # Check that the email is allowed for current community
    if @current_community && ! @current_community.email_allowed?(params[:person][:email])
      flash[:error] = t("people.new.email_not_allowed")
      redirect_to error_redirect_path and return
    end
    
    @person = Person.new
    if APP_CONFIG.use_recaptcha && @current_community && @current_community.use_captcha && !verify_recaptcha_unless_already_accepted(:model => @person, :message => t('people.new.captcha_incorrect'))
        
      # This should not actually ever happen if all the checks work at Sharetribe's end.
      # Anyway if Captha responses with error, show message to user
      # Also notify admins that this kind of error happened.
      # TODO: if this ever happens, should change the message to something else than "unknown error"
      flash[:error] = :unknown_error
      ApplicationHelper.send_error_notification("New user Sign up failed because Captha check failed, when it shouldn't.", "Captcha error")
      redirect_to error_redirect_path and return
    end


    params[:person][:locale] =  params[:locale] || APP_CONFIG.default_locale
    params[:person][:test_group_number] = 1 + rand(4)
    
    # skip email confirmation unless it's required in this community
    params[:person][:confirmed_at] = (@current_community.email_confirmation ? nil : Time.now) if @current_community
    
    params[:person][:show_real_name_to_other_users] = false unless (params[:person][:show_real_name_to_other_users] || (@current_community && !@current_community.select_whether_name_is_shown_to_everybody))
    
    # Try to create a new person in ASI.
    begin

      params["person"].delete(:terms) #remove terms part which confuses Devise
      
      # This part is copied from Devise's regstration_controller#create
      build_resource
      @person = resource
      if @person.save
        sign_in(resource_name, resource)
      end
    
      @person.set_default_preferences
      # Make person a member of the current community
      if @current_community
        membership = CommunityMembership.new(:person => @person, :community => @current_community, :consent => @current_community.consent)
        membership.invitation = invitation if invitation.present?
        membership.save!
      end
    rescue RestClient::RequestFailed => e
      logger.info "Person create failed because of #{JSON.parse(e.response.body)["messages"]}"
      # This should not actually ever happen if all the checks work at Sharetribe's end.
      # Anyway if ASI responses with error, show message to user
      # Now it's unknown error, since picking the message from ASI and putting it visible without translation didn't work for some reason.
      # Also notify admins that this kind of error happened.
      flash[:error] = :unknown_error
      ApplicationHelper.send_error_notification("New user Sign up failed because ASI returned: #{JSON.parse(e.response.body)["messages"]}", "Signup error")
      redirect_to error_redirect_path and return
    end
    session[:person_id] = @person.id
    
    # If invite was used, reduce usages left
    invitation.use_once! if invitation.present?
    
    Delayed::Job.enqueue(CommunityJoinedJob.new(@person.id, @current_community.id, request.host)) if @current_community
    
    if !@current_community
      session[:consent] = APP_CONFIG.consent
      session[:unconfirmed_email] = params[:person][:email]
      session[:allowed_email] = "@#{params[:person][:email].split('@')[1]}" if community_email_restricted?
      redirect_to domain + new_tribe_path
    elsif @current_community.email_confirmation
      flash[:notice] = "account_creation_succesful_you_still_need_to_confirm_your_email"
      redirect_to :controller => "sessions", :action => "confirmation_pending"
    else
      flash[:notice] = [:login_successful, (@person.given_name_or_username + "!").to_s, person_path(@person)]
      redirect_to(session[:return_to].present? ? domain + session[:return_to]: domain + root_path)
    end
  end
  
  def create_facebook_based
    username = Person.available_username_based_on(session["devise.facebook_data"]["username"])
    
    person_hash = {
      :username => username,
      :given_name => session["devise.facebook_data"]["given_name"],
      :family_name => session["devise.facebook_data"]["family_name"],
      :email => session["devise.facebook_data"]["email"],
      :facebook_id => session["devise.facebook_data"]["id"],
      :locale => I18n.locale,
      :test_group_number => 1 + rand(4),
      :confirmed_at => Time.now,  # We trust that Facebook has already confirmed these and save the user few clicks
      :password => Devise.friendly_token[0,20]
    }
    @person = Person.create!(person_hash)
    @person.set_default_preferences

    @person.store_picture_from_facebook
    

    session[:person_id] = @person.id    
    sign_in(resource_name, @person)
    flash[:notice] = [:login_successful, (@person.given_name_or_username + "!").to_s, person_path(@person)]
    
    # We don't create the community membership yet, because we can use the already existing checks for invitations and email types.
    redirect_to :controller => :community_memberships, :action => :new
  end
  
  def update
    
	  if params[:person] && params[:person][:location] && (params[:person][:location][:address].empty?) || (params[:person][:street_address].blank? || params[:person][:street_address].empty?)
      params[:person].delete("location")
      if @person.location
        @person.location.delete
      end
	  end
	  
	  #Check that people don't exploit changing email to be confirmed to join an email restricted community
	  if params["request_new_email_confirmation"] && @current_community && ! @current_community.email_allowed?(params[:person][:email])
	    flash[:error] = t("people.new.email_not_allowed")
	    redirect_to :back and return
    end
    
    # If person is changing email address, store the old confirmed address as additional email
    # One point of this is that same email cannot be used more than one in email restricted community
    # (This has to be remembered also when creating a possibility to modify additional emails)
    if params[:person][:email] && @person.confirmed_at
      Email.create(:person => @person, :address => @person.email, :confirmed_at => @person.confirmed_at) unless Email.find_by_address(@person.email)
    end
	  
    begin
      if @person.update_attributes(params[:person], session[:cookie])
        if params[:person][:password]
          #if password changed Devise needs a new sign in.
          sign_in @person, :bypass => true
        end
        flash[:notice] = :person_updated_successfully
        
        # Send new confirmation email, if was changing for that 
        if params["request_new_email_confirmation"]
            @person.send_confirmation_instructions
            flash[:notice] = :email_confirmation_sent_to_new_address
        end
      else
        flash[:error] = @person.errors.first
      end
    rescue RestClient::RequestFailed => e
      flash[:error] = "update_error"
    end
    
    redirect_to :back
    
  end
  
  def update_avatar
    if params[:person] && params[:person][:image] && @person.update_attributes(params[:person])
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
  
  #This checks also that email is allowed for this community
  def check_email_availability_and_validity
    
    # If asked from dashboard, only check availability
    return check_email_availability if @current_community.nil?
    
    
    available = true
    
    #first check if the community allows this email
    if @current_community.allowed_emails.present?
      available = @current_community.email_allowed?(params[:person][:email])
    end
    
    if available
      # Then check if it's already in use
      check_email_availability
    else #respond false  
      respond_to do |format|
        format.json { render :json => available }
      end
    end
  end
  
  # this checks only that email is not already in use
  def check_email_availability
    email = params[:person] ? params[:person][:email] : params[:email]
    available = email_available_for_user?(@current_user, email)
    
    respond_to do |format|
      format.json { render :json => available }
    end
  end
  
  # this checks only that email is not already in use
  def check_email_availability_for_new_tribe
    email = params[:person] ? params[:person][:email] : params[:email]
    if email_available_for_user?(@current_user, email)
      existing_communities = Community.find_by_allowed_email(email)
      if existing_communities.size > 0 && Community.email_restricted?(params[:community_category])
        available = restricted_tribe_already_exists_error_message(existing_communities.first)      
      else
        available = true
      end
    else
      available = t("communities.signup_form.email_in_use_message")
    end
    
    respond_to do |format|
      format.json { render :json => available.to_json }
    end
  end
  
  #This checks only that email is valid
  def check_email_validity
    valid = true
    if @current_community.allowed_emails.present?
      valid = @current_community.email_allowed?(params[:community_membership][:email])
    end
    respond_to do |format|
      format.json { render :json => valid }
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
  
  def choose_layout
    if @current_community && @current_community.private && action_name.eql?("new")
      'private'
    else
      'application'
    end
  end
  
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
  
end
