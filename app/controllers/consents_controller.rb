class ConsentsController < ApplicationController
  
    def show
      redirect_to root_path unless session[:temp_cookie]
      clear_navi_state
    end
    
    # Used to accept the consent for existing OtaSizzle users
    def accept
      @current_user = Person.add_to_kassi_db(session[:temp_person_id])
      @current_user.settings = Settings.create
      session[:cookie] = session[:temp_cookie]
      session[:person_id] = session[:temp_person_id]
      session[:temp_cookie] = nil
      session[:temp_person_id] = nil
      flash[:notice] = :consent_accepted
      if session[:return_to]
        redirect_to session[:return_to]
        session[:return_to] = nil
      else
        redirect_to root_path
      end
    end
    
end
