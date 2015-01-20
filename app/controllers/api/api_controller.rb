class Api::ApiController < ApplicationController
  include ApiHelper

  skip_filter :cannot_access_without_joining
  skip_filter :fetch_community_admin_status
  skip_filter :fetch_community_plan_expiration_status
  skip_before_filter :verify_authenticity_token

  before_filter :ensure_api_enabled
  before_filter :set_pagination

  respond_to :atom

  layout false

  protected

  def ensure_api_enabled
    #puts "CALL TO API, WITH VERSION SPECIFIED TO #{api_version}"
    unless APP_CONFIG.api_enabled
      render status: :forbidden, xml: ["API is not enabled on this server"]
    end
  end

  def set_pagination
    @page = params["page"] || 1
    @per_page = params["per_page"] || 50
  end

end
