require 'json'

class Session < ActiveResource::Base

  attr_accessor :username
  attr_writer   :password
  attr_accessor :app_name
  attr_writer   :app_password
  attr_reader   :headers
  attr_reader   :person_id
  
  self.site = APP_CONFIG.ssl_asi_url #POISTA
  # self.format = :json 
  # self.timeout = APP_CONFIG.asi_timeout
  @@cookie = nil
  
  @@session_uri = "#{APP_CONFIG.ssl_asi_url}/session"
  
  # Creates a session by logging in to Aalto Social Interface (ASI)
  def create
    @headers = {}
    params = {:session => {}}
    params[:session][:username] = @username if @username
    params[:session][:password] = @password if @password
    params[:session][:app_name] = @app_name || APP_CONFIG.asi_app_name
    params[:session][:app_password] = @app_password || APP_CONFIG.asi_app_password
    
    resp = RestHelper.make_request(:post, @@session_uri, params , nil, true)

    @headers["Cookie"] = resp[1].headers[:set_cookie].to_s
    @person_id = resp[0]["entry"]["user_id"] 
  end
  
  def initialize(params={})
    self.username = params[:username]
    self.password = params[:password]
    self.app_name = params[:app_name]
    self.app_password = params[:app_password]
    super(params)
  end
  
  # A class method for destroying a session based on cookie
  def self.destroy(cookie)
    deleting_headers = {"Cookie" => cookie}
    resp = RestHelper.make_request(:delete, @@session_uri, deleting_headers, nil, true)
    
  end
  
  def destroy
    Session.destroy(@headers["Cookie"])
  end
  
  #Use only for session containing a user (NO app-only session)
  def self.get_by_cookie(cookie)
    new_session = Session.new
    new_session.cookie = cookie

    return nil unless new_session.set_person_id()   
    return new_session
  end
  
  #a general app-only session cookie that maintains an open session to ASI for Kassi
  def self.kassiCookie
    if @@cookie.nil?
      @@cookie = Session.create.cookie
    end
    return @@cookie
  end
  
  #this method can be called, if kassiCookie is not valid anymore
  def self.updateKassiCookie
    @@cookie = Session.create.cookie
  end
  
  # Posts a GET request to ASI for this session
  def check
    begin
      return RestHelper.get(@@session_uri, @headers)
    rescue RestClient::ResourceNotFound => e
      return nil
    end
  end
    

  
  def cookie
    @headers["Cookie"]
  end
  
  def cookie=(cookie)
    @headers ||= {}
    @headers["Cookie"] = cookie
  end
  
  def set_person_id
    info = self.check
    return nil if (info.nil? || info["entry"].nil?)
    @person_id =  info["entry"]["user_id"]
    return @person_id
  end
end
