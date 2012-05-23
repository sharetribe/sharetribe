class InfosController < ApplicationController
  
  skip_filter :check_email_confirmation, :dashboard_only
  
  def about
  end
  
  def how_to_use
  end

  def terms
  end
  
  def register_details
  end

end
