class InfosController < ApplicationController

  skip_filter :check_email_confirmation, :dashboard_only

  def about
    @selected_tribe_navi_tab = "about"
    @selected_left_navi_link = "about"
  end

  def how_to_use
    @selected_tribe_navi_tab = "about"
    @selected_left_navi_link = "how_to_use"
    case(how_to_use_content?)
    when None, Some(false)
      raise ActiveRecord::RecordNotFound
    else
      render locals: { how_to_use_content: @community_customization.how_to_use_page_content }
    end
  end

  def terms
    @selected_tribe_navi_tab = "about"
    @selected_left_navi_link = "terms"
  end

  def privacy
    @selected_tribe_navi_tab = "about"
    @selected_left_navi_link = "privacy"
  end

  private

  def how_to_use_content?
    Maybe(@community_customization).map { |customization| !customization.how_to_use_page_content.nil? }
  end
end
