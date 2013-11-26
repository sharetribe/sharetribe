# Note: This controller is called "MercuryUpdateController" because "MercuryController"
# is an internal controller of Mercury. DO NOT rename this class to MercuryController!
class MercuryUpdateController < ApplicationController
  
  skip_filter :dashboard_only
  
  before_filter :ensure_is_admin
  
  # Update content with WYSIWYG editor Mercury
  def update
    attribute = params[:content_type].to_sym
    if @community_customization
      @community_customization.update_attribute(attribute, params[:content][:page_content][:value])
    else
      @current_community.community_customizations.create(:locale => I18n.locale, attribute => params[:content][:page_content][:value])
    end
    render text: ""
  end
  
end