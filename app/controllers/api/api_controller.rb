class Api::ApiController < ApplicationController
  skip_filter :single_community_only
  skip_filter :dashboard_only
  skip_filter :fetch_community

  before_filter :set_correct_mime_type
  
  
  protected
  
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

  
end