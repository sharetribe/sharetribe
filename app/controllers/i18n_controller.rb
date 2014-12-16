class I18nController < ApplicationController

  # Changes locale and returns to the previous view
  def change_locale
    @current_user.update_attribute(:locale, params[:locale]) if @current_user
    redirect_to("/#{params[:locale]}/#{params[:redirect_uri]}")
  end

end
