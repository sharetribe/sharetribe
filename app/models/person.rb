require 'json'

class Person < ActiveRecord::Base
  
  attr_accessor :guid, :password, :username, :email
  
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
    
    def self.get_person(id, cookie)
      #puts "#{prefix}#{element_name}/#{id}/@self"
      #puts ({"Cookie" => cookie }.inspect)
      return connection.get("#{prefix}#{element_name}/#{id}/@self", {"Cookie" => cookie } )
    end
    
    def self.put_attributes(params, id, cookie)
      connection.put("#{prefix}#{element_name}/#{id}/@self",{:person => params}.to_json, {"Cookie" => cookie} )
      
    end
  end
  
  
  def self.create(params, cookie)
    # create to Common Services
    person_hash = {:person => params.slice(:username, :password, :email) }
    response = PersonConnection.create_person(person_hash, cookie)
    params[:id] = response.body[/"id": "([^"]+)"/, 1]
    params[:cos_cookie] = cookie
    #puts "createssa #{cookie}"
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
      test_person = Person.create({ :username => "kassi_testperson1", 
                      :password => "testi", 
                      :email => "kassi_testperson1@example.com"},
                       session.headers["Cookie"])
    rescue ActiveRecord::RecordNotFound  => e
        test_person = Person.add_to_kassi_db(session.person_id, session.headers["Cookie"])
    end
  end
  
  def self.add_to_kassi_db(id, cos_cookie)
    person = Person.new({:id => id, :cos_cookie => cos_cookie })
    if person.save
      return person
    else
      return nil
      logger.error { "Error stroring person to Kassi DB with ID: #{id}" }
    end
  end

  def initialize(params={})
    self.guid = params[:id] #store GUID to temporary attribute
    #puts "initializessa #{params[:cos_cookie]}"
    super(params)
  end
  
  def after_initialize
    self.id ||= self.guid
  end
  
  def username
    return nil if ! self.cos_cookie
    person_hash = PersonConnection.get_person(self.id, self.cos_cookie)
    return person_hash["username"]
   end
  
  def name_or_username
      #puts (PersonConnection.get_person(self.id, self.cos_cookie).inspect)
    person_hash = PersonConnection.get_person(self.id, self.cos_cookie)
    if person_hash["name"] && person_hash["name"]["unstructured"]
      return person_hash["name"]["unstructured"]
    else
      return person_hash["username"]
    end
  end
  
  def name
    return name_or_username
  end
  
  def given_name=(name)
    update_attributes({:name => {:given_name => name, } })
  end
  
  def family_name=(name)
    update_attributes({:name => {:family_name => name, } })
  end
  
  def update_attributes(params)
    PersonConnection.put_attributes(params, self.id,self.cos_cookie)
  end
  
end
  

