class I18nController < ApplicationController

  skip_filter :single_community_only

  # Changes locale and returns to the previous view
  def change_locale
    @current_user.update_attribute(:locale, params[:locale]) if @current_user
    redirect_to("/#{params[:locale]}/#{params[:redirect_uri]}")
  end

end
