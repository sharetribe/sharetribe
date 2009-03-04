class ConsentsController < ApplicationController
  
    def show
      if session[:locale] == "en-US"
        render :template => "consents/consent_en"
      else
        render :template => "consents/consent_fi"
      end    
    end
    
    def show_research_information
      #TODO language choice
         render :template => "consents/research_information_fi"
    end
    
    def show_agreement
      #TODO language choice
        render :template => "consents/service_agreement_fi"
    end
    
    def accept
      @current_user = Person.add_to_kassi_db(session[:temp_person_id])
      session[:cookie] = session[:temp_cookie]
      session[:person_id] = session[:temp_person_id]
      if session[:return_to]
        redirect_to session[:return_to]
        session[:return_to] = nil
      else
        redirect_to root_path
      end
    end
    
    def decline
      redirect_to root_path
    end
    
end
