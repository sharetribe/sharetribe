class SettingsController < ApplicationController
  
  before_filter :logged_in
  
  def show
    @person = Person.find(params[:person_id])
    return unless must_be_current_user(@person)
    save_navi_state(['own','settings'])
    @person.settings = Settings.create unless @person.settings
  end
  
  def change_email
    @person = Person.find(params[:person_id])
    return unless must_be_current_user(@person)
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
    return unless must_be_current_user(@person)
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
  
  def change_language
    @person = Person.find(params[:person_id])
    @person.update_attribute(:locale, params[:person_locale])
    flash[:notice] = :language_updated_successfully
    redirect_to person_settings_path(@person)
  end
  
  def update
    @person = Person.find(params[:person_id])
    return unless must_be_current_user(@person)
    @person.settings.update_attributes(params[:settings])
    flash[:notice] = :settings_updated_successfully
    redirect_to person_settings_path(@person)
  end
  
end
