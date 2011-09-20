class ConfirmationsController < Devise::ConfirmationsController
  
  skip_filter :check_email_confirmation
  
  # This is directly copied from Devise::ConfirmationsController
  # to be able to handle better the situations of resending confirmation and
  # confirmation attemt with wrong token.
  
  # POST /resource/confirmation
  def create
    self.resource = resource_class.send_confirmation_instructions(params[resource_name])

    if successful_and_sane?(resource)
      set_flash_message(:notice, :send_instructions) if is_navigational_format?
      #respond_with({}, :location => after_resending_confirmation_instructions_path_for(resource_name))
      redirect_to :controller => "sessions", :action => "confirmation_pending" # This is changed from Devise's default
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
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      #respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render_with_scope :new }
      
      # This is changed from Devise's default
      flash[:error] = "confirmation_link_is_wrong_or_used"
      redirect_to root_path
    end
  end
  
end