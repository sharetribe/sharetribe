class ConsentsController < ApplicationController
  
    def show
      if session[:locale] == "fi"
        #logger.info { "FINNISH" }
        render:template => "consents/consent_fi"
      else
        render:template => "consents/consent_en"
      end    
    end
    
    def show_research_information
      if session[:locale] = "fi"
        #logger.info { "FINNISH" }
        render:template => "consents/research_information_fi"
      else
        #logger.info { "ENGLISH" }
      end
    end
    
    def show_agreement
      if session[:locale] = "fi"
        #logger.info { "FINNISH" }
        render:template => "consents/service_agreement_fi"
      else
        #logger.info { "ENGLISH" }
      end
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
