class InfosController < ApplicationController

  skip_filter :check_email_confirmation, :dashboard_only
  
  before_filter :ensure_is_admin, :only => [ :mercury_update ]
  
  def about
    @selected_tribe_navi_tab = "about"
    @selected_left_navi_link = "about"
  end
  
  def how_to_use
    @selected_tribe_navi_tab = "about"
    @selected_left_navi_link = "how_to_use"
  end

  def terms
    @selected_tribe_navi_tab = "about"
    @selected_left_navi_link = "terms"
    @mangopay_in_use = @current_community.payment_gateways.include?(Mangopay.first)
  end
  
  def privacy
    @selected_tribe_navi_tab = "about"
    @selected_left_navi_link = "privacy"
  end
  
  def mercury_update
    if @community_customization
      @community_customization.update_attribute(:about_page_content, params[:content][:page_content][:value])
    else
      @current_community.community_customizations.create(:locale => I18n.locale, :about_page_content => params[:content][:page_content][:value])
    end
    render text: ""
  end

end
