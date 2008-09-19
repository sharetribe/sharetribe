require 'json'

class Person < ActiveRecord::Base
  
  attr_accessor :guid, :username, :password, :email
  
  validates_confirmation_of :password, :on => :create, :message => "Given passwords are not same"
  
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
    
    def self.get_person(id)
      connection.get("#{prefix}#{element_name}/#{id}/@self")
    end
  end
  
  
  def self.create(params, cookie)
    #return nil if params.nil?
    
    # create to Common Services
    person_hash = {:person => params.slice(:username, :password, :email) }
    response = PersonConnection.create_person(person_hash, cookie)
    params[:id] = response.body[/"id": "([^"]+)"/, 1]
    #create locally with less attributes
    super(params.except(:username, :email))
  end
  
  # def self.add_to_kassi_db(id)
  #   
  # end

  def initialize(params={})
    self.guid = params[:id] #store GUID to temporary attribute
    super(params)
  end
  
  def after_initialize
    self.id ||= self.guid
  end
  
  def given_name
    "Matti"
  end
  
  def family_name
    "Meikäläinen"
  end
  
  def name
    #person_json = JSON.parse(PersonConnection.get_person(self.id).body)
    #return json["name"]["unstructured"]
    "Masa Mäki"
  end
  
end
  

