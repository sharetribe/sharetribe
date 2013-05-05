class ConfirmationsController < Devise::ConfirmationsController
  
  skip_filter :check_email_confirmation, :cannot_access_without_joining
  skip_filter :dashboard_only
  skip_filter :single_community_only
  
  # This is directly copied from Devise::ConfirmationsController
  # to be able to handle better the situations of resending confirmation and
  # confirmation attemt with wrong token.
  
  # POST /resource/confirmation
  def create
    if params[:person] && params[:person][:email] && ! @current_user.has_email?(params[:person][:email]) && @current_community
      # If user submitted the email change form, change the email before sending again.
      if Person.email_available?(params[:person][:email])
        if @current_community.email_allowed?(params[:person][:email])
          if params[:person][:email_to_change] && @current_user.has_email?(params[:person][:email_to_change])
            @current_user.change_email(params[:person][:email_to_change], params[:person][:email])
            @current_user.send_email_confirmation_to(params[:person][:email], request.host_with_port)
            flash[:notice] = t("sessions.confirmation_pending.check_your_email")
            redirect_to :controller => "sessions", :action => "confirmation_pending" and return
          else
            @current_user.update_attribute(:email, params[:person][:email])
          end
        else
          flash[:error] = t("people.new.email_not_allowed")
          redirect_to :controller => "sessions", :action => "confirmation_pending" and return
        end
      else
        flash[:error] = t("people.new.email_is_in_use")
        redirect_to :controller => "sessions", :action => "confirmation_pending" and return
      end
    end
    
    # If looks like were confirming here a company email on dashboard, send manually 
    if session[:unconfirmed_email] && 
           session[:allowed_email] &&
           session[:unconfirmed_email].match(session[:allowed_email]) && 
           @current_user.has_email?(session[:unconfirmed_email]) 
      @current_user.send_email_confirmation_to(session[:unconfirmed_email], request.host_with_port)
      flash[:notice] = t("sessions.confirmation_pending.account_confirmation_instructions_dashboard")
      redirect_to new_tribe_path and return
    
    elsif params[:person][:email] && params[:person][:email] != @current_user.email # resend confirmation for an additional email
      @current_user.send_email_confirmation_to(params[:person][:email], request.host_with_port)
      flash[:notice] = t("sessions.confirmation_pending.check_your_email")
      redirect_to :controller => "sessions", :action => "confirmation_pending" and return
    
    else #resend confirmation for primary email
      self.resource = resource_class.send_confirmation_instructions(resource_params)
      if successfully_sent?(resource)
        if on_dashboard?
          flash[:notice] = t("sessions.confirmation_pending.account_confirmation_instructions_dashboard")
          redirect_to new_tribe_path and return
        else
          set_flash_message(:notice, :send_instructions) if is_navigational_format?
          redirect_to :controller => "sessions", :action => "confirmation_pending" # This is changed from Devise's default
        end
      else
        respond_with(resource)
      end
    end

    
  end
  
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    if params[:confirmation_token]
      #sometimes tests catch extra ' char with link, so remove it if there
      params[:confirmation_token] = params[:confirmation_token].chomp("'") 
    end
    
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(resource_name, resource)
      @current_user = current_person
      if on_dashboard?
        redirect_to new_tribe_path
      else
        @current_community.approve_pending_membership(@current_user, @current_user.email)
        PersonMailer.welcome_email(@current_user, @current_community).deliver
        respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
      end
    else
      #check if this confirmation code matches to additional emails
      if e = Email.find_by_confirmation_token(params[:confirmation_token])
        e.confirmed_at = Time.now
        e.confirmation_token = nil
        e.save
        
        # This redirect expects that additional emails are only added when joining a community that requires it
        if on_dashboard?
          redirect_to new_tribe_path and return
        else
          # Accept pending community membership if needed
          @current_community.approve_pending_membership(@current_user, e.address)
            
          PersonMailer.welcome_email(@current_user, @current_community).deliver
          flash[:notice] = t("layouts.notifications.additional_email_confirmed")
          redirect_to root and return
        end
      end
      
      #respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render_with_scope :new }
      # This is changed from Devise's default
      flash[:error] = t("layouts.notifications.confirmation_link_is_wrong_or_used")
      if @current_user
        if on_dashboard?
          redirect_to new_tribe_path
        else
          redirect_to :controller => "sessions", :action => "confirmation_pending"
        end
      else
        redirect_to :root
      end
    end
  end
  
end