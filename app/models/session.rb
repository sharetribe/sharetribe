class Session < ActiveResource::Base
 

  attr_accessor :username
  attr_accessor :password
 
  self.site = "http://cos.sizl.org"
  #self.site = "http://maps.cs.hut.fi/cos"
  
  self.format = :json 
  self.timeout = 5
  @@app_password = "Xk4z5iZ"
  @@app_name = "kassi"
  @username
  @password
  @headers
 
  #self.element_name = "session"
  #self.collection_name = "session" #exceptionally not plural, bacause COS requires "session"
  
  #class << self
  #   def element_path(id, prefix_options = {}, query_options = nil)
  #     prefix_options, query_options = split_options(prefix_options) if query_options.nil?
  #     # path to the resource, which we want to access is evaluated in this statement: 
  #     "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
  #   end
  # 
  #   def collection_path(prefix_options = {}, query_options = nil)
  #     #puts prefix_options.inspect + "LASDFOIHASFGIOAUBHAEGAHDSIGU"
  #     prefix_options, query_options = split_options(prefix_options) if query_options.nil?
  #     "#{prefix(prefix_options)}#{collection_name}#{simplify_parameters(query_string(query_options))}?app_name=kassi&app_password=Xk4z5iZ"
  #   end
  #end

  
  def self.login(params = {})
    session = new
    session.username = params[:username]
    session.password = params[:password]
    session.save
    return session
  end
  
  #this is added to class methods to get access to private method query_string
  def self.to_query_string(params)
      query_string(params)
      #TODO find a better way to do this...
  end
  
  def create #params = {})
    @headers = {}
    params = {}
    params[:username] = @username if @username
    params[:password] = @password if @password
    params.update({:app_name => @@app_name, :app_password => @@app_password})
    resp = connection.post("#{self.class.prefix}#{self.class.element_name}#{self.class.to_query_string(params)}")
    #puts @headers["Cookie"]
    @headers["Cookie"] = resp.get_fields("set-cookie").to_s
  end
  
  def check
    get("")
  end
  def get(path)
    connection.get("#{self.class.prefix}#{self.class.element_name}", @headers)
  end
   
  def destroy
    connection.delete("#{self.class.prefix}#{self.class.element_name}", @headers)
  end
end
