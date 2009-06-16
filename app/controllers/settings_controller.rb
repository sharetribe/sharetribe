class SettingsController < ApplicationController
  
  before_filter :logged_in
  
  def show
    save_navi_state(['own','settings'])
    @person = Person.find(params[:person_id])
    @person.settings = Settings.create unless @person.settings
  end
  
  def change_email
    @person = Person.find(params[:person_id])
    begin
      @person.update_attributes(params[:person], session[:cookie])
    rescue RestClient::RequestFailed => e
      if e.response.body.include?("taken")
        flash[:error] = :email_has_already_been_taken
      else
        flash[:error] = :email_is_invalid
      end    
      redirect_to person_settings_path(@person) and return
    end
    flash[:notice] = :email_updated_successfully
    redirect_to person_settings_path(@person)
  end
  
  def change_password
    @person = Person.find(params[:person_id])
    unless params[:person][:password].eql?(params[:person][:password2])
      flash[:error] = :passwords_dont_match
      redirect_to person_settings_path(@person) and return  
    end
    begin
      @person.update_attributes(params[:person].except("password2"), session[:cookie])
    rescue RestClient::RequestFailed => e
      flash[:error] = :password_is_invalid
      redirect_to person_settings_path(@person) and return
    end
    flash[:notice] = :password_updated_successfully
    redirect_to person_settings_path(@person)
  end
  
  def update
    @person = Person.find(params[:person_id])
    @person.settings.update_attributes(params[:settings])
    flash[:notice] = :settings_updated_successfully
    redirect_to person_settings_path(@person)
  end
  
end
