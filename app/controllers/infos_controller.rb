class InfosController < ApplicationController
  
  def about
    save_navi_state(['info','about','',''])
  end

  def help
    save_navi_state(['info','help','',''])
  end

  def terms
    save_navi_state(['info','terms','',''])
  end

end
