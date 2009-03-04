require 'json'

class Person < ActiveRecord::Base
  
  attr_accessor :guid, :password, :password2, :username, :email
  attr_protected :is_admin

  has_many :feedbacks

  has_many :listings
  
  has_many :items, :foreign_key => "owner_id"
  
  has_many :available_items, 
           :class_name => "Item",
           :foreign_key => "owner_id", 
           :conditions => "status <> 'disabled'",
           :order => "title"
           
  has_many :disabled_items, 
           :class_name => "Item",
           :foreign_key => "owner_id",
           :conditions => "status = 'disabled'",
           :order => "title"
                    
  has_many :available_favors, 
           :class_name => "Favor",
           :foreign_key => "owner_id", 
           :conditions => "status <> 'disabled'",
           :order => "title"
  
  has_many :disabled_favors, 
           :class_name => "Favor",
           :foreign_key => "owner_id", 
           :conditions => "status = 'disabled'",
           :order => "title"
  
  has_many :favors

  has_many :person_interesting_listings
  has_many :interesting_listings, 
           :through => :person_interesting_listings, 
           :source => :listing
           
  has_many :person_conversations
  has_many :conversations, 
           :through => :person_conversations, 
           :source => :conversation
  
  has_and_belongs_to_many :kassi_events
  
  has_many :received_comments, 
           :class_name => "PersonComment", 
           :foreign_key => "target_person_id"

  class PersonConnection < ActiveResource::Base
    # This is an inner class to handle remote connection to COS database where the actual information
    # of person model is stored. This is subclass of ActiveResource so it includes some automatic
    # functionality to access REST interface.
    #
    # In practise we use here connection.post/get/put/delete and the URL and Parameters as described
    # in COS documentation at #{COS_URL}

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
      return fix_alphabets(connection.get("#{prefix}#{element_name}/#{id}/@self", {"Cookie" => cookie }))
    end
    
    def self.search(query, cookie)
      return fix_alphabets(connection.get("#{prefix}#{element_name}?search=" + query, {"Cookie" => cookie} ))
    end
    
    def self.get_friends(id, cookie)
      return fix_alphabets(connection.get("#{prefix}#{element_name}/#{id}/@friends", {"Cookie" => cookie }))
    end
    
    def self.get_pending_friend_requests(id, cookie)
      return fix_alphabets(connection.get("#{prefix}#{element_name}/#{id}/@pending_friend_requests", {"Cookie" => cookie }))
    end
    
    def self.put_attributes(params, id, cookie)
      connection.put("#{prefix}#{element_name}/#{id}/@self",{:person => params}.to_json, {"Cookie" => cookie} )   
    end
    
    def self.update_avatar(image, id, cookie)
      connection.put("#{prefix}#{element_name}/#{id}/@avatar", {:file => image}, {"Cookie" => cookie} )
    end
    
    def self.add_as_friend(friend_id, id, cookie)
      connection.post("#{prefix}#{element_name}/#{id}/@friends", {:friend_id => friend_id}.to_json, {"Cookie" => cookie} )
    end
    
    def self.remove_from_friends(friend_id, id, cookie)
      connection.delete("#{prefix}#{element_name}/#{id}/@friends/#{friend_id}", {"Cookie" => cookie} )
    end
    
    def self.remove_pending_friend_request(friend_id, id, cookie)
      connection.delete("#{prefix}#{element_name}/#{id}/@pending_friend_requests/#{friend_id}", {"Cookie" => cookie} )
    end
    
    #fixes utf8 letters
    def self.fix_alphabets(json_hash)
      #the parameter must be a hash that is decoded from JSON by activeResource messing up umlaut letters
      JSON.parse(json_hash.to_json.gsub(/\\\\u/,'\\u'))
    end
    
  end
  
  def self.create(params, cookie)
    # create to Common Services
    person_hash = {:person => params.slice(:username, :password, :email) }
    response = PersonConnection.create_person(person_hash, cookie)
    #pick id from the response (same id in kassi and COS DBs)
    params[:id] = response.body[/"id":"([^"]+)"/, 1]
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
  
  def self.search(query)
    cookie = Session.kassiCookie
    begin
      person_hash = PersonConnection.search(query, cookie)
    rescue ActiveResource::ResourceNotFound => e
      #Could not find person with that id in COS Database!
      return nil
    end  
    return person_hash
  end
  
  def username(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    return person_hash["username"]
  end
  
  def name_or_username(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    if person_hash["name"] && person_hash["name"]["unstructured"] && person_hash["name"]["unstructured"] =~ /\S/
      return person_hash["name"]["unstructured"]
    else
      return person_hash["username"]
    end
  end
  
  def name(cookie=nil)
    return name_or_username(cookie)
  end
  
  def given_name(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["name"].nil?
    return person_hash["name"]["given_name"]
  end
  
  def set_given_name(name, cookie)
    update_attributes({:name => {:given_name => name, } }, cookie)
  end
  
  def family_name(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["name"].nil?
    return person_hash["name"]["family_name"]
  end
  
  def set_family_name(name, cookie)
    update_attributes({:name => {:family_name => name, } }, cookie)
  end
  
  def address(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    return person_hash["unstructured_address"]
  end
  
  def set_address(address, cookie)
    update_attributes({:unstructured_address => address}, cookie)
  end
  
  def street_address(cookie=nil)
    person_hash = get_person_hash(cookie)
  end
  
  def phone_number(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["phone_number"]
  end
  
  def set_phone_number(number, cookie)
    update_attributes({:phone_number => number}, cookie)
  end
  
  def email(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["email"]
  end
  
  def set_email(email, cookie)
    update_attributes({:email => email}, cookie)
  end
  
  def password(cookie = nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["password"]
  end
  
  def set_password(password, cookie)
    update_attributes({:password => password}, cookie)
  end
  
  def add_as_friend(friend_id, cookie)
    PersonConnection.add_as_friend(friend_id, self.id, cookie)
  end
  
  def remove_from_friends(friend_id, cookie)
    PersonConnection.remove_from_friends(friend_id, self.id, cookie)
  end
  
  def remove_pending_friend_request(friend_id, cookie)
    PersonConnection.remove_from_friends(friend_id, self.id, cookie)
  end
  
  def get_friends(cookie)
    
    begin
      friend_hash = PersonConnection.get_friends(self.id, cookie)
    rescue ActiveResource::ResourceNotFound => e
      #Could not find person with that id in COS Database!
      return nil
    end
    
    return friend_hash
  end
  
  def get_friend_requests(cookie)
    
    begin
      request_hash = PersonConnection.get_pending_friend_requests(self.id, cookie)
    rescue ActiveResource::ResourceNotFound => e
      #Could not find person with that id in COS Database!
      return nil
    end
    
    return request_hash
  end
  
  def update_attributes(params, cookie)
    #Handle name part parameters also if they are in hash root level
    if params['given_name'] && (params['name'].nil? || params['name']['given_name'].nil?)
      params.update({'name' => Hash.new}) if params['name'].nil?
      params['name'].update({'given_name' => params['given_name']})
      params.delete('given_name')
    end
    if params['family_name'] && (params['name'].nil? || params['name']['family_name'].nil?)
      params.update({'name' => Hash.new}) if params['name'].nil?
      params['name'].update({'family_name' => params['family_name']})
      params.delete('family_name')
    end
    
    if params['address']
      params.update({'unstructured_address' => params['address']})
      params.delete('address')
    end
      
    PersonConnection.put_attributes(params, self.id, cookie)
    #clear old data from cache
    Rails.cache.delete("person_hash.#{id}")
  end
  
  def update_avatar(image, cookie)
    PersonConnection.update_avatar(image, self.id, cookie)
  end
  
  def get_person_hash(cookie=nil)
    cookie = Session.kassiCookie if cookie.nil?
    
    begin
      person_hash = Rails.cache.fetch("person_hash.#{id}") {PersonConnection.get_person(self.id, cookie)}
    rescue ActiveResource::UnauthorizedAccess => e
      cookie = Session.updateKassiCookie
      person_hash = PersonConnection.get_person(self.id, cookie)
      Rails.cache.write("person_hash.#{id}", person_hash)
    rescue ActiveResource::ResourceNotFound => e
      #Could not find person with that id in COS Database!
      return nil
    end
    
    return person_hash
  end
  
  def friend_status(cookie = nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    return person_hash["connection"]
  end
  
  def save_item(item)
    existing_item = disabled_items.find_by_title(item.title)
    if existing_item
      existing_item.description = item.description
      if existing_item.save
        existing_item.enable
        return true
      else
        item.errors.add(:description, "is too long")
      end  
    else
      return true if item.save
    end  
    return false
  end
  
  def save_favor(favor)
    existing_favor = disabled_favors.find_by_title(favor.title)
    if existing_favor
      existing_favor.description = favor.description
      if existing_favor.save
        existing_favor.enable
        return true
      else
        favor.errors.add(:description, "is too long")
      end  
    else
      return true if favor.save
    end  
    return false
  end
  
end
