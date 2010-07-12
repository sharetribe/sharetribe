class I18nController < ApplicationController
  
  # Changes locale and returns to the previous view
  def change_locale
    redirect_to "/#{params[:locale]}/#{params[:redirect_uri]}"
  end
  
end  