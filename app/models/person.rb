class Person < ActiveRecord::Base
  
  attr_accessor :guid, :username, :password, :email
  
  class PersonConnection < ActiveResource::Base
    self.site = Session::COS_URL
    self.format = :json 
    self.timeout = Session::COS_TIMEOUT
    self.element_name = "people"
    self.collection_name = "people"
    
    def self.create_person(params, cookie)
      creating_headers = {"Cookie" => cookie}
      response = connection.post("#{prefix}#{element_name}", params.to_json ,creating_headers)
    end
  end
  
  
  def self.create(params, cookie)
    #return nil if params.nil?
    
    # create to Common Services
    person_hash = {:person => params.slice(:username, :password, :email) }
    response = PersonConnection.create_person(person_hash, cookie)
    params[:id] = response.body[/"id": "([^"]+)"/, 1]
    #create locally with less attributes
    super(params.except(:username, :password, :email))
  end
  
  # def self.add_to_kassi_db(id)
  #   
  # end

  def initialize(params={})
    #puts params[:id] if ! params.nil?
    self.guid = params[:id] #store GUID to temporary attribute
    super(params)
  end
  
  def after_initialize
    #puts "AFTER_INITIALIZE BEF self.id = #{self.id} ja self.guid= #{self.guid}"    
    self.id ||= self.guid
    #puts "AFTER_INITIALIZE AFT self.id = #{self.id} ja self.guid= #{self.guid}"    
  end
  
end
  

