class InfosController < ApplicationController
  
  def show
    redirect_to :action => :about
  end
  
  def about
    save_navi_state(['info','about','',''])
    if session[:locale] == "en"
      render :template => "infos/_about_en"
    else
      render :template => "infos/_about_fi"
    end
  end

  def help
    save_navi_state(['info','help','',''])
    if session[:locale] == "en"
      render :template => "infos/_help_en"
    else
      render :template => "infos/_help_fi"
    end
  end

  def terms
    save_navi_state(['info','terms','',''])
    @not_first_time = true
    if session[:locale] == "en"
      render :template => "consents/_terms_en"
    else
      render :template => "consents/_terms_fi"
    end
  end

end
