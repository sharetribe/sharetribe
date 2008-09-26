require 'json'

class Session < ActiveResource::Base
 
  #URL for Common Services
  #COS_URL = "http://cos.sizl.org"
  COS_URL = "http://maps.cs.hut.fi/cos"
  COS_TIMEOUT = 8

  attr_accessor :username
  attr_writer   :password
  attr_reader   :headers
  attr_reader   :person_id
 
  self.site = COS_URL
  self.format = :json 
  self.timeout = COS_TIMEOUT
  @@app_password = "Xk4z5iZ"
  @@app_name = "kassi"
  
  def self.destroy(cookie)
    deleting_headers = {"Cookie" => cookie}
    connection.delete("#{prefix}#{element_name}", deleting_headers)
  end
  
  
  #this is added to class methods to get access to private method query_string
  def self.to_query_string(params)
      query_string(params)
      #TODO find a better way to do this...
  end
  
  def initialize(params={})
    self.username = params[:username]
    self.password = params[:password]
    super(params)
  end
  
  def create
    @headers = {}
    params = {}
    params[:username] = @username if @username
    params[:password] = @password if @password
    params.update({:app_name => @@app_name, :app_password => @@app_password})
    resp = connection.post("#{self.class.prefix}#{self.class.element_name}", params.to_json)
    #resp = connection.post("#{self.class.prefix}#{self.class.element_name}#{self.class.to_query_string(params)}")
    @headers["Cookie"] = resp.get_fields("set-cookie").to_s
    json = JSON.parse(resp.body)
    @person_id = json["user_id"]
    
  end
  
  def check
    get("")
  end
  
  def get(path)
    connection.get("#{self.class.prefix}#{self.class.element_name}", @headers)
  end
   
  def destroy
    Session.destroy(@headers["Cookie"])
    #connection.delete("#{self.class.prefix}#{self.class.element_name}", @headers)
  end
  
  def cookie
    @headers["Cookie"]
  end
end
