# Note: This controller is called "MercuryUpdateController" because "MercuryController"
# is an internal controller of Mercury. DO NOT rename this class to MercuryController!
class MercuryUpdateController < ApplicationController

  skip_filter :dashboard_only

  before_filter :ensure_is_admin

  # Update content with WYSIWYG editor Mercury
  def update
    param_hash = params[:content].inject({}) do |memo, content_hash|
      content_type, content_attributes = content_hash
      memo[content_type] = content_attributes[:value]
      memo
    end

    if @community_customization
      @community_customization.update_attributes(param_hash)
    else
      @current_community.community_customizations.create(param_hash.merge({:locale => I18n.locale}))
    end
    render text: ""
  end

end
