class TermsController < ApplicationController
  
  def show
    redirect_to root_path unless session[:temp_cookie]
    current_community = Community.find(session[:temp_community_id])
    logger.info "Consent changed 1: #{session[:consent_changed]}"
    @current_user = nil
    logger.info "Consent changed 2: #{session[:consent_changed]}"
  end
  
  def accept
    if session[:consent_changed]
      @current_user = Person.find_by_id(session[:temp_person_id])
      current_community = Community.find(session[:temp_community_id])
      @current_user.community_memberships.find_by_community_id(current_community.id).update_attribute(:consent, current_community.consent) 
    else
      @current_user = Person.add_to_kassi_db(session[:temp_person_id])
      @current_user.set_default_preferences
      @current_user.update_attribute(:locale, (params[:locale] || APP_CONFIG.default_locale))
      @current_user.communities << @current_community
    end
    session[:cookie] = session[:temp_cookie]
    session[:person_id] = session[:temp_person_id]
    session[:temp_cookie] = session[:temp_person_id] = nil
    session[:temp_community_id] = nil
    session[:consent_changed] = nil
    flash[:notice] = [:login_successful, (@current_user.given_name + "!").to_s, person_path(@current_user)]
    redirect_to (session[:return_to] || root)
  end
  
end
