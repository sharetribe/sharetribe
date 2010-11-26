class PeopleController < ApplicationController
  
  before_filter :only => [ :update, :update_avatar ] do |controller|
    controller.ensure_authorized "you_are_not_authorized_to_view_this_content"
  end
  
  helper_method :show_closed?
  
  def index
    # this is not yet in use in this version of Kassi, but old URLs point here so implement this to avoid errors
   render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404
  end
  
  def show
    @person = Person.find(params[:id])
    @listings = params[:type] && params[:type].eql?("requests") ? @person.requests : @person.offers
    @listings = show_closed? ? @listings : @listings.open 
    @listings = @listings.visible_to(@current_user).order("open DESC, id DESC").paginate(:per_page => 15, :page => params[:page])
    render :partial => "listings/additional_listings" if request.xhr?
  end

  def new
    @person = Person.new
  end

  def create
    
    #if the request came from different domain, redirects back there.
    domain = request.headers["HTTP_ORIGIN"] || ""
    
    @person = Person.new
    if APP_CONFIG.use_recaptcha && !verify_recaptcha_unless_already_accepted(:model => @person, :message => t('people.new.captcha_incorrect'))
        
      # This should not actually ever happen if all the checks work at Kassi's end.
      # Anyway if Captha responses with error, show message to user
      # Also notify Hoptoad that this kind of error happened.
      # TODO: if this ever happens, should change the message to something else than "unknown error"
      flash[:error] = :unknown_error
      HoptoadNotifier.notify(
                 :error_class => "Special Error", 
                 :error_message => "New user Sign up failed because Captha check failed, when it shouldn't." 
               )
      redirect_to domain + sign_up_path and return
    end

    # Open a Session first only for Kassi to be able to create a user
    @session = Session.create
    session[:cookie] = @session.cookie
    params[:person][:locale] =  params[:locale] || APP_CONFIG.default_locale
    params[:person][:test_group_number] = 1 + rand(4)

    # Try to create a new person in ASI.

    begin
      @person = Person.create(params[:person], session[:cookie])
      @person.set_default_preferences
    rescue RestClient::RequestFailed => e
      logger.info "Failed because of #{JSON.parse(e.response.body)["messages"]}"
      
      # This should not actually ever happen if all the checks work at Kassi's end.
      # Anyway if ASI responses with error, show message to user
         # Now it's unknown error, since picking the message from ASI and putting it visible without translation didn't work for some reason.
      # Also notify Hoptoad that this kind of error happened.
      flash[:error] = :unknown_error
      HoptoadNotifier.notify(
                 :error_class => "Special Error", 
                 :error_message => "New user Sign up failed because ASI returned: #{JSON.parse(e.response.body)["messages"]}" 
               )
      redirect_to domain + sign_up_path and return#{}"/#{I18n.locale}/signup"
    end
    session[:person_id] = @person.id
    flash[:notice] = [:login_successful, (@person.given_name + "!").to_s, person_path(@person)]
    redirect_to (session[:return_to].present? ? domain + session[:return_to]: domain + root_path)

  end
  
  def update
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
    available = nil
    if @current_user && (@current_user.email == params[:person][:email])
      # Current user's own email should not be shown as unavailable
      available = true
    else
      available = Person.email_available?(params[:person][:email])
    end
    
    respond_to do |format|
      format.json { render :json => available }
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
  
end
