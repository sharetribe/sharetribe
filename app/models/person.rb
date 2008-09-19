require 'json'

class Person < ActiveRecord::Base
  
  attr_accessor :guid, :password
  
  has_many :listings
  
  has_many :interesting_listings
  has_many :int_listings, :through => :interesting_listings, :source => :listing
  
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
    # create to Common Services
    person_hash = {:person => params.slice(:username, :password, :email) }
    response = PersonConnection.create_person(person_hash, cookie)
    params[:id] = response.body[/"id": "([^"]+)"/, 1]
    params[:cos_cookie] = cookie
    #create locally with less attributes
    super(params.except(:username, :email))
  end
  
  ##
  # returns a test person. If doesn't exist already, creates him.
  
  def self.test_person
    session = nil
    test_person = nil
    
    #frist try loggin in to cos
    begin
      session = Session.create({:username => "kassi_testperson1", :password => "testi" })
      #try to find in kassi database
      test_person = Person.find(session.person_id)

    rescue ActiveResource::UnauthorizedAccess => e
      #if not found, create completely new
      session = Session.create
      session.headers["Cookie"]
      test_person = Person.create({ :username => "kassi_testperson1", 
                      :password => "testi", 
                      :email => "kassi_testperson1@example.com"},
                       session.headers["Cookie"])
    rescue ActiveRecord::RecordNotFound  => e
        test_person = Person.add_to_kassi_db(session.person_id)
    end
  end
  
  def self.add_to_kassi_db(id)
    person = Person.new({:id => id })
    if person.save
      return person
    else
      return nil
    end
  end

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
  

