class SettingsController < ApplicationController
  
  before_filter :logged_in
  
  def show
    save_navi_state(['own','settings'])
    @person = Person.find(params[:person_id])
  end
  
  def change_email
    @person = Person.find(params[:person_id])
    begin
      @person.update_attributes(params[:person], session[:cookie])
    rescue ActiveResource::BadRequest => e
      flash[:error] = :email_is_invalid
      redirect_to person_settings_path(@person) and return
    end
    flash[:notice] = :email_updated_successfully
    redirect_to person_settings_path(@person)
  end
  
  def change_password
    
  end
  
end
