class TermsController < ApplicationController
  
  def show
    redirect_to root_path unless session[:temp_cookie]
  end
  
  def accept
    @current_user = Person.add_to_kassi_db(session[:temp_person_id])
    @current_user.set_default_preferences
    @current_user.update_attribute(:locale, (params[:locale] || APP_CONFIG.default_locale))
    @current_user.communities << @current_community
    session[:cookie] = session[:temp_cookie]
    session[:person_id] = session[:temp_person_id]
    session[:temp_cookie] = session[:temp_person_id] = nil
    flash[:notice] = [:login_successful, (@current_user.given_name + "!").to_s, person_path(@current_user)]
    redirect_to (session[:return_to] || root)
  end
  
end
