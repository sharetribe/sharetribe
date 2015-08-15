class I18nController < ApplicationController

  # When we change the locale, we should not redirect to the old locale
  skip_filter :redirect_locale_param

  # Changes locale and returns to the previous view
  def change_locale
    @current_user.update_attribute(:locale, params[:locale]) if @current_user
    redirect_to("/#{params[:locale]}/#{params[:redirect_uri]}")
  end

end
