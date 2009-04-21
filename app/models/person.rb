require 'json'

class Person < ActiveRecord::Base
  
  PERSON_HASH_CACHE_EXPIRE_TIME = 5
  
  attr_accessor :guid, :password, :password2, :username, :email, :form_username, :form_password, :form_password2, :form_email
  
  attr_protected :is_admin

  has_many :feedbacks

  has_many :listings
  
  has_many :items, :foreign_key => "owner_id"

  # Can't be used because conditions parameter can't be passed from controller
  # has_many :available_items, 
  #          :class_name => "Item",
  #          :foreign_key => "owner_id", 
  #          :conditions => "status <> 'disabled'",
  #          :order => "title"
           
  has_many :disabled_items, 
           :class_name => "Item",
           :foreign_key => "owner_id",
           :conditions => "status = 'disabled'",
           :order => "title"
  
  # Can't be used because conditions parameter can't be passed from controller                  
  # has_many :available_favors, 
  #          :class_name => "Favor",
  #          :foreign_key => "owner_id", 
  #          :conditions => "status <> 'disabled'",
  #          :order => "title"
  
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
           
  has_one :settings         

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
      #Rails.cache.delete("person_hash.#{id}_asked_with_cookie.#{cookie}")
    end
    
    def self.update_avatar(image, id, cookie)
      connection.put("#{prefix}#{element_name}/#{id}/@avatar", {:file => image}, {"Cookie" => cookie} )
    end
    
    def self.add_as_friend(friend_id, id, cookie)
      connection.post("#{prefix}#{element_name}/#{id}/@friends", {:friend_id => friend_id}.to_json, {"Cookie" => cookie} )
      #Rails.cache.delete("person_hash.#{id}_asked_with_cookie.#{cookie}")
      #Rails.cache.delete("person_hash.#{friend_id}_asked_with_cookie.#{cookie}")
    end
    
    def self.remove_from_friends(friend_id, id, cookie)
      connection.delete("#{prefix}#{element_name}/#{id}/@friends/#{friend_id}", {"Cookie" => cookie} )
      #Rails.cache.delete("person_hash.#{id}_asked_with_cookie.#{cookie}")
      #Rails.cache.delete("person_hash.#{friend_id}_asked_with_cookie.#{cookie}")
    end
    
    def self.remove_pending_friend_request(friend_id, id, cookie)
      connection.delete("#{prefix}#{element_name}/#{id}/@pending_friend_requests/#{friend_id}", {"Cookie" => cookie} )
      #Rails.cache.delete("person_hash.#{id}_asked_with_cookie.#{cookie}")
      #Rails.cache.delete("person_hash.#{friend_id}_asked_with_cookie.#{cookie}")
    end
    
    def self.get_groups(id, cookie)
      return fix_alphabets(connection.get("#{prefix}#{element_name}/#{id}/@groups", {"Cookie" => cookie }))
    end
    
    def self.join_group(id, group_id, cookie)
      creating_headers = {"Cookie" => cookie}
      response = connection.post("#{prefix}#{element_name}/#{id}/@groups", {:group_id => group_id}.to_json, creating_headers)
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
    if new_record?
      return form_username ? form_username : ""
    end
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
    update_attributes({:name => {:family_name => name } }, cookie)
  end
  
  def street_address(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["address"].nil?
    return person_hash["address"]["street_address"]
  end
  
  def set_street_address(street_address, cookie)
    update_attributes({:address => {:street_address => street_address } }, cookie)
  end
  
  def postal_code(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["address"].nil?
    return person_hash["address"]["postal_code"]
  end
  
  def set_postal_code(postal_code, cookie)
    update_attributes({:address => {:postal_code => postal_code } }, cookie)
  end
  
  def locality(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["address"].nil?
    return person_hash["address"]["locality"]
  end
  
  def set_locality(locality, cookie)
    update_attributes({:address => {:locality => locality } }, cookie)
  end
  
  def unstructured_address(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["address"].nil?
    return person_hash["address"]["unstructured"]
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
    if new_record?
      return form_email ? form_email : ""
    end
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["email"]
  end
  
  def set_email(email, cookie)
    update_attributes({:email => email}, cookie)
  end
  
  def password(cookie = nil)
    if new_record?
      return form_password ? form_password : ""
    end
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["password"]
  end
  
  def set_password(password, cookie)
    update_attributes({:password => password}, cookie)
  end
  
  def password2
    if new_record?
      return form_password2 ? form_password2 : ""
    end
  end
  
  # Returns contacts of this person as an array of Person objects 
  def contacts
    Person.find_by_sql(contact_query("id, created_at"))
  end
  
  # Returns a query that gets the selected attributes for contacts
  def contact_query(select)
    "SELECT #{select} 
    FROM 
      people, kassi_events_people 
    WHERE
      id = person_id AND
      person_id <> '#{id}' AND 
      kassi_event_id IN (
        SELECT kassi_event_id FROM kassi_events_people WHERE person_id = '#{id}'
      )"
  end
  
  # Returns friends of this person as an array of Person objects
  def friends(cookie)
    Person.find_kassi_users_by_ids(get_friend_ids(cookie))
  end
  
  # Returns ids of OtaSizzle friends of this person
  def get_friend_ids(cookie)
    Person.get_person_ids(get_friends(cookie))
  end
  
  # Returns those people who are also kassi users
  def self.find_kassi_users_by_ids(ids)
    Person.find_by_sql("SELECT * FROM people WHERE id IN ('" + ids.join("', '") + "')")
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
  
  # Retrieves friends of this person from COS
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
  
  # Returns all the groups that this user is a member in 
  # as an array of Group objects
  def groups(cookie)
    Group.find(get_group_ids(cookie))
  end
  
  # Returns ids of OtaSizzle groups of this person
  def get_group_ids(cookie)
    Group.get_group_ids(get_groups(cookie))
  end
  
  # Returns a hash from COS containing groups of this person
  def get_groups(cookie)
    
    begin
      group_hash = PersonConnection.get_groups(self.id, cookie)
    rescue ActiveResource::ResourceNotFound => e
      #Could not find person with that id in COS Database!
      return nil
    end
    
    return group_hash
  end
  
  def update_attributes(params, cookie)
    #Handle name part parameters also if they are in hash root level
    remove_root_level_fields(params, "name", ["given_name", "family_name"])
    remove_root_level_fields(params, "address", ["street_address", "postal_code", "locality"])      
    PersonConnection.put_attributes(params, self.id, cookie)
  end
  
  def remove_root_level_fields(params, field_type, fields)
    fields.each do |field|
      if params[field] && (params[field_type].nil? || params[field_type][field].nil?)
        params.update({field_type => Hash.new}) if params[field_type].nil?
        params[field_type].update({field => params[field]})
        params.delete(field)
      end
    end  
  end
  
  def update_avatar(image, cookie)
    PersonConnection.update_avatar(image, self.id, cookie)
  end
  
  def get_person_hash(cookie=nil)
    cookie = Session.kassiCookie if cookie.nil?
    
    begin
      #person_hash = Rails.cache.fetch("person_hash.#{id}_asked_with_cookie.#{cookie}", :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME) {PersonConnection.get_person(self.id, cookie)}
      person_hash = PersonConnection.get_person(self.id, cookie)
    rescue ActiveResource::UnauthorizedAccess => e
      cookie = Session.updateKassiCookie
      person_hash = PersonConnection.get_person(self.id, cookie)
      #Rails.cache.write("person_hash.#{id}_asked_with_cookie.#{cookie}",  person_hash, :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME)
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
  
  def available_items(conditions)
    Item.find :all, 
              :conditions => ["owner_id = '#{id}' AND status <> 'disabled'" + conditions],
              :order => "title"
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
  
  def available_favors(conditions)
    Favor.find :all, 
              :conditions => ["owner_id = '#{id}' AND status <> 'disabled'" + conditions],
              :order => "title"
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
  
  def join_group(group_id, cookie)
    PersonConnection.join_group(self.id, group_id, cookie)
  end
  
  # Takes a person hash from COS and extracts ids from it
  # into an array.
  def self.get_person_ids(person_hash)
    person_hash["entry"].collect { |person| person["id"] }
  end
  
end
