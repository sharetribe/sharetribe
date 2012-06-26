class Api::ApiController < ApplicationController
  skip_filter :single_community_only
  skip_filter :dashboard_only
  skip_filter :fetch_community

  skip_before_filter :verify_authenticity_token
  
  prepend_before_filter :get_api_key
  before_filter :ensure_api_enabled, :set_correct_mime_type
  
  #version 1
  
  respond_to :json
    
  layout false
  
  protected
  
  # def rabl(object, template_name = "#{controller_name}/#{action_name}", options = {})
  #   render_json Rabl.render(object, template_name, :view_path => Rails.root.join('app/views'), :format => :json, :scope => self)
  # end
  
  def ensure_api_enabled
    unless APP_CONFIG.api_enabled
      render :status => :forbidden, :json => ["API is not enabled on this server"]
    end
  end
  
  def set_correct_mime_type
    # puts "ACCEPT: ->"
    # puts request.env['HTTP_ACCEPT']
    # puts request.format
    # puts "VERSION #{api_version}"

    if  request.env['HTTP_ACCEPT'].match /application\/vnd\.sharetribe\+json/
      request.format = :json
    end
  end  
  

  def api_version
    default_version = 'alpha'
    pattern = /application\/vnd\.sharetribe.*version=([\d]+)/
    request.env['HTTP_ACCEPT'][pattern, 1] || default_version
  end
  

  def get_api_key
    if api_token = params[:api_token].blank? && request.headers["Sharetribe-API-Token"]
      params[:api_token] = api_token
    end
  end

  
end