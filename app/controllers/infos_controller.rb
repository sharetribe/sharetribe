class InfosController < ApplicationController
  
  def show
    redirect_to :action => :about
  end
  
  def about
    save_navi_state(['info','about','',''])
  end

  def help
    save_navi_state(['info','help','',''])
  end

  def terms
    save_navi_state(['info','terms','',''])
    @not_first_time = true
    #TODO english version of terms
    render :template => "consents/_terms_fi"
  end

end
