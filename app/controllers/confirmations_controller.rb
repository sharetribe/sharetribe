class ConfirmationsController < Devise::ConfirmationsController
  
  skip_filter :check_email_confirmation, :cannot_access_without_joining
  skip_filter :check_hobbies_submitted
  skip_filter :dashboard_only
  skip_filter :single_community_only
  
  # This is directly copied from Devise::ConfirmationsController
  # to be able to handle better the situations of resending confirmation and
  # confirmation attemt with wrong token.
  
  # POST /resource/confirmation
  def create
    self.resource = resource_class.send_confirmation_instructions(params[resource_name])

    if successfully_sent?(resource)
      #respond_with({}, :location => after_resending_confirmation_instructions_path_for(resource_name))
      if on_dashboard?
        flash[:notice] = t("sessions.confirmation_pending.account_confirmation_instructions_dashboard")
        redirect_to new_tribe_path
      else
        set_flash_message(:notice, :send_instructions) if is_navigational_format?
        redirect_to :controller => "sessions", :action => "confirmation_pending" # This is changed from Devise's default
      end
    else
      respond_with_navigational(resource){ render_with_scope :new }
    end
  end
  
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(resource_name, resource)
      if on_dashboard?
        redirect_to new_tribe_path
      else
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
          flash[:notice] = "additional_email_confirmed"
          redirect_to :controller => "community_memberships", :action => "new" and return
        end
      end
      
      #respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render_with_scope :new }
      # This is changed from Devise's default
      flash[:error] = "confirmation_link_is_wrong_or_used"
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
