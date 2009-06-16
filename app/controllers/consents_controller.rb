class ConsentsController < ApplicationController
  
    def show
      @accept_action = "accept"
      display_consent
    end
    
    def register
      @accept_action = "accept_and_register"
      display_consent
    end
    
    def show_research_information
      #TODO language choice
         render :template => "consents/research_information_fi"
    end
    
    def show_agreement
      #TODO language choice
        render :template => "consents/service_agreement_fi"
    end
    
    # Used to accept the consent for existing OtaSizzle users
    def accept
      @current_user = Person.add_to_kassi_db(session[:temp_person_id])
      @current_user.settings = Settings.create
      session[:cookie] = session[:temp_cookie]
      session[:person_id] = session[:temp_person_id]
      if session[:return_to]
        redirect_to session[:return_to]
        session[:return_to] = nil
      else
        redirect_to root_path
      end
    end
    
    # Used to accept the consent 
    def accept_and_register
      session[:consent_accepted] = true
      redirect_to new_person_path
    end
    
    def decline
      session[:consent_accepted] = nil
      redirect_to root_path
    end
    
    private
    
    def display_consent
      if session[:locale] == "en"
        render :template => "consents/consent_en"
      else
        render :template => "consents/consent_fi"
      end
    end
    
end
