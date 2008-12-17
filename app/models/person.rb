require 'json'

class Person < ActiveRecord::Base
  
  attr_accessor :guid, :password, :username, :email
  attr_protected :is_admin

  has_many :feedbacks

  has_many :listings
  
  has_many :items, :conditions => "owner_id = '" + self.object_id.to_s + "'"
  
  has_many :favors

  has_many :person_interesting_listings
  has_many :interesting_listings, :through => :person_interesting_listings, :source => :listing
           
  has_many :person_conversations
  has_many :conversations, :through => :person_conversations, :source => :conversation
  
  has_and_belongs_to_many :kassi_events
  
  has_many :received_comments, :class_name => "PersonComment", :foreign_key => "target_person_id"
  
  validates_confirmation_of :password, :on => :create, :message => "Given passwords are not same"

  class PersonConnection < ActiveResource::Base
    self.site = COS_URL
    self.format = :json 
    self.timeout = COS_TIMEOUT
    self.element_name = "people"
    self.collection_name = "people"
    
    def self.create_person(params, cookie)
      creating_headers = {"Cookie" => cookie}
      response = connection.post("#{prefix}#{element_name}", params.to_json ,creating_headers)
    end
    
    def self.get_person(id, cookie)
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
    #create locally with less attributes
    super(params.except(:username, :email))
  end 
  
  def self.add_to_kassi_db(id)
    person = Person.new({:id => id })
    if person.save
      return person
    else
      return nil
      logger.error { "Error storing person to Kassi DB with ID: #{id}" }
    end
  end

  def initialize(params={})
    self.guid = params[:id] #store GUID to temporary attribute
    super(params)
  end
  
  def after_initialize
    #self.id may already be correct in this point so use ||=
    self.id ||= self.guid
  end
  
  def username(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    return person_hash["username"]
  end
  
  def name_or_username(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    if person_hash["name"] && person_hash["name"]["unstructured"]
      return person_hash["name"]["unstructured"]
    else
      return person_hash["username"]
    end
  end
  
  def name(cookie)
    return name_or_username(cookie)
  end
  
  def set_given_name(name, cookie)
    update_attributes({:name => {:given_name => name, } }, cookie)
  end
  
  def set_family_name(name, cookie)
    update_attributes({:name => {:family_name => name, } }, cookie)
  end
  
  def address(cookie)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["unstructured_address"]
  end
  
  def set_address(address, cookie)
    update_attributes({:unstructured_address => address}, cookie)
  end
  
  def phone_number(cookie)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["phone_number"]
  end
  
  def set_phone_number(number, cookie)
    update_attributes({:phone_number => number}, cookie)
  end
  
  # def email(cookie)
  #   person_hash = get_person_hash(cookie)
  #   return "Person not found!" if person_hash.nil?
  #   
  #   return person_hash["email"]
  # end
  # 
  # def set_email(email, cookie)
  #   update_attributes({:email => email}, cookie)
  # end
  # 
  def update_attributes(params, cookie)
    PersonConnection.put_attributes(params, self.id, cookie)
  end
  
  def get_person_hash(cookie=nil)
    cookie = Session.kassiCookie if cookie.nil?
    
    begin
      person_hash = PersonConnection.get_person(self.id, cookie)
    rescue ActiveResource::UnauthorizedAccess => e
      cookie = Session.updateKassiCookie
      person_hash = PersonConnection.get_person(self.id, cookie)
    rescue ActiveResource::ResourceNotFound => e
      #Could not find person with that id in COS Database!
      return nil
    end
    
    return person_hash
  end
end
