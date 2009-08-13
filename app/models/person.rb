require 'json'
require 'rest_client'
require 'httpclient'

class Person < ActiveRecord::Base
 
  PERSON_HASH_CACHE_EXPIRE_TIME = 15
  
  attr_accessor :guid, :password, :password2, :username, :email, :form_username, :form_given_name, :form_family_name, :form_password, :form_password2, :form_email
  
  attr_protected :is_admin

  has_many :feedbacks

  has_many :listings, :dependent => :destroy, :foreign_key => "author_id"
  
  has_many :items, :foreign_key => "owner_id", :dependent => :destroy
           
  has_many :disabled_items, 
           :class_name => "Item",
           :foreign_key => "owner_id",
           :conditions => "status = 'disabled'",
           :order => "title",
           :dependent => :destroy 
  
  has_many :disabled_favors, 
           :class_name => "Favor",
           :foreign_key => "owner_id", 
           :conditions => "status = 'disabled'",
           :order => "title",
           :dependent => :destroy 
  
  has_many :favors, :foreign_key => "owner_id", :dependent => :destroy 

  has_many :person_interesting_listings, :dependent => :destroy 
  has_many :interesting_listings, 
           :through => :person_interesting_listings, 
           :source => :listing
           
  has_many :person_conversations, :dependent => :destroy 
  has_many :conversations, 
           :through => :person_conversations, 
           :source => :conversation
  
  has_many :received_comments, 
           :class_name => "PersonComment", 
           :foreign_key => "target_person_id",
           :dependent => :destroy,
           :order => "id DESC" 
           
  has_many :kassi_event_participations, :dependent => :destroy
  has_many :kassi_events, 
           :through => :kassi_event_participations, 
           :source => :kassi_event
           
  has_one :settings, :dependent => :destroy          

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
      JSON.parse(RestClient.post("#{COS_URL}/#{element_name}", params, {:cookies => cookie}))
      # creating_headers = {"Cookie" => cookie}
      #  response = connection.post("#{prefix}#{element_name}", params.to_json ,creating_headers)
    end
    
    def self.get_person(id, cookie)
      JSON.parse(RestClient.get("#{COS_URL}/#{element_name}/#{id}/@self", {:cookies => cookie}))
      
      # return fix_alphabets(connection.get("#{prefix}#{element_name}/#{id}/@self", {"Cookie" => cookie }))
    end
    
    def self.search(query, cookie)
      escaped_query = URI.escape(query, Regexp.new("[^-_!~*()a-zA-Z\\d]")) # Should use escape_for_url method in ApplicationHelper
      JSON.parse(RestClient.get("#{COS_URL}/#{element_name}?search=#{escaped_query}", {:cookies => cookie}))
      #return fix_alphabets(connection.get("#{prefix}#{element_name}?search=" + query, {"Cookie" => cookie} ))
    end
    
    def self.get_friends(id, cookie)
      JSON.parse(RestClient.get("#{COS_URL}/#{element_name}/#{id}/@friends", {:cookies => cookie}))
      #puts "FRIENDS HAUN TULOS: #{response.inspect}"
      #return fix_alphabets(connection.get("#{prefix}#{element_name}/#{id}/@friends", {"Cookie" => cookie }))
    end
    
    def self.get_pending_friend_requests(id, cookie)
      JSON.parse(RestClient.get("#{COS_URL}/#{element_name}/#{id}/@pending_friend_requests", {:cookies => cookie}))
      #return fix_alphabets(connection.get("#{prefix}#{element_name}/#{id}/@pending_friend_requests", {"Cookie" => cookie }))
    end
    
    def self.put_attributes(params, id, cookie)
      JSON.parse(RestClient.put("#{COS_URL}/#{element_name}/#{id}/@self", {:person => params}, {:cookies => cookie}))
      #connection.put("#{prefix}#{element_name}/#{id}/@self",{:person => params}.to_json, {"Cookie" => cookie} )
      # information changes, clear cache
      parent.cache_delete(id,cookie)
    end
    
    def self.update_avatar(image, id, cookie)
      HTTPClient.post("#{COS_URL}/#{element_name}/#{id}/@avatar", { :file => image})
      
      #RestClient.put("#{COS_URL}/#{element_name}/#{id}/@avatar", {:file => image}, {:cookies => cookie})
      #connection.put("#{prefix}#{element_name}/#{id}/@avatar", {:file => image}, {"Cookie" => cookie} )
    end
    
    def self.add_as_friend(friend_id, id, cookie)
      RestClient.post("#{COS_URL}/#{element_name}/#{id}/@friends", {:friend_id => friend_id}, {:cookies => cookie})
      #connection.post("#{prefix}#{element_name}/#{id}/@friends", {:friend_id => friend_id}.to_json, {"Cookie" => cookie} )
      #Rails.cache.delete("person_hash.#{id}_asked_with_cookie.#{cookie}")
      parent.cache_delete(id,cookie)
      #Rails.cache.delete("person_hash.#{friend_id}_asked_with_cookie.#{cookie}")
      parent.cache_delete(friend_id,cookie)
    end
    
    def self.remove_from_friends(friend_id, id, cookie)
      RestClient.delete("#{COS_URL}/#{element_name}/#{id}/@friends/#{friend_id}", {:cookies => cookie})   
      #connection.delete("#{prefix}#{element_name}/#{id}/@friends/#{friend_id}", {"Cookie" => cookie} )
      #Rails.cache.delete("person_hash.#{id}_asked_with_cookie.#{cookie}")
      parent.cache_delete(id,cookie)
      #Rails.cache.delete("person_hash.#{friend_id}_asked_with_cookie.#{cookie}")
      parent.cache_delete(friend_id,cookie)
    end
    
    def self.remove_pending_friend_request(friend_id, id, cookie)
      RestClient.delete("#{COS_URL}/#{element_name}/#{id}/@pending_friend_requests/#{friend_id}", {:cookies => cookie})
      
      #connection.delete("#{prefix}#{element_name}/#{id}/@pending_friend_requests/#{friend_id}", {"Cookie" => cookie} )
      #Rails.cache.delete("person_hash.#{id}_asked_with_cookie.#{cookie}")
      parent.cache_delete(id,cookie)
      #Rails.cache.delete("person_hash.#{friend_id}_asked_with_cookie.#{cookie}")
      parent.cache_delete(friend_id,cookie)
    end
    
    def self.get_groups(id, cookie, event_id=nil)
      request_url = "#{COS_URL}/#{element_name}/#{id}/@groups"
      request_url += "?event_id=#{event_id}" if event_id
      JSON.parse(RestClient.get(request_url, {:cookies => cookie}))
      #return fix_alphabets(connection.get("#{prefix}#{element_name}/#{id}/@groups", {"Cookie" => cookie }))
    end
    
    def self.join_group(id, group_id, cookie)
      JSON.parse(RestClient.post("#{COS_URL}/#{element_name}/#{id}/@groups", {:group_id => group_id}, {:cookies => cookie}))
      #response = connection.post("#{prefix}#{element_name}/#{id}/@groups", { :group_id => group_id }.to_json, {"Cookie" => cookie})
    end
    
    def self.leave_group(id, group_id, cookie)
      JSON.parse(RestClient.delete("#{COS_URL}/#{element_name}/#{id}/@groups/#{group_id}", {:cookies => cookie}))
      
      #response = connection.delete("#{prefix}#{element_name}/#{id}/@groups/#{group_id}", {"Cookie" => cookie})
    end
    
    #fixes utf8 letters
    # def self.fix_alphabets(json_hash)
    #   #the parameter must be a hash that is decoded from JSON by activeResource messing up umlaut letters
    #   #puts json_hash.inspect
    #   JSON.parse(json_hash.to_json.gsub(/\\\\u/,'\\u'))
    # end
    
  end
  
  # Create a new person to Common Services and Kassi.
  def self.create(params, cookie)
    
    # Try to create the person to COS
    person_hash = {:person => params.slice(:username, :password, :email) }
    response = PersonConnection.create_person(person_hash, cookie)
    
    # Pick id from the response (same id in kassi and COS DBs)
    puts response.inspect
    params[:id] = response["entry"]["id"]
    puts params[:id]
    #params[:id] = response[/"id":"([^"]+)"/, 1]
    
    # Add name information for the person to COS 
    params[:given_name] = params[:given_name].slice(0, 28)
    params[:family_name] = params[:family_name].slice(0, 28)
    Person.remove_root_level_fields(params, "name", ["given_name", "family_name"])  
    PersonConnection.put_attributes(params.except(:username, :email, :password, :password2), params[:id], cookie)
    
    # Create locally with less attributes 
    super(params.except(:username, :email, :name))
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
    rescue RestClient::ResourceNotFound => e
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
    if new_record?
      return form_given_name ? form_given_name : ""
    end
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["name"].nil?
    return person_hash["name"]["given_name"]
  end
  
  def set_given_name(name, cookie)
    update_attributes({:name => {:given_name => name, } }, cookie)
  end
  
  def family_name(cookie=nil)
    if new_record?
      return form_family_name ? form_family_name : ""
    end
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
    Person.find_by_sql(contact_query("people.id, people.created_at"))
  end
  
  # Returns a query that gets the selected attributes for contacts
  def contact_query(select)
    "SELECT DISTINCT #{select} 
    FROM 
      people, kassi_event_participations
    WHERE
      people.id = person_id AND
      person_id <> '#{id}' AND 
      kassi_event_id IN (
        SELECT kassi_event_id FROM kassi_event_participations WHERE person_id = '#{id}'
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
    
      # rescue is commented out to spot the error cases more clearly
    
    # begin
      friend_hash = PersonConnection.get_friends(self.id, cookie)
    # rescue RestClient::ResourceNotFound => e
    #   #Could not find person with that id in COS Database!
    #   return nil
    # end
    
    return friend_hash
  end
  
  def get_friend_requests(cookie)
    
      # rescue is commented out to spot the error cases more clearly
    
    # begin
      request_hash = PersonConnection.get_pending_friend_requests(self.id, cookie)
    # rescue RestClient::ResourceNotFound => e
    #    #Could not find person with that id in COS Database!
    #    return nil
    #  end
    
    return request_hash
  end
  
  # Returns all the groups that this user is a member in 
  # as an array of Group objects
  # if some of the groups are not already in kassi database, add them
  def groups(cookie, event_id=nil)
    group_ids = get_group_ids(cookie, event_id)
    begin
      return Group.find(group_ids)
    rescue ActiveRecord::RecordNotFound
      Group.add_new_groups_to_kassi_db(group_ids)
      return Group.find(group_ids)
    end
  end
  
  # Returns ids of OtaSizzle groups of this person
  def get_group_ids(cookie, event_id=nil)
    Group.get_group_ids(get_groups(cookie, event_id))
  end
  
  # Returns a hash from COS containing groups of this person
  def get_groups(cookie, event_id=nil)
    
    # rescue is commented out to spot the error cases more clearly
    
    # begin
      group_hash = PersonConnection.get_groups(self.id, cookie, event_id)
    # rescue RestClient::ResourceNotFound => e
    #   #Could not find person with that id in COS Database!
    #   return nil
    # end
    
    return group_hash
  end
  
  def update_attributes(params, cookie)
    #Handle name part parameters also if they are in hash root level
    Person.remove_root_level_fields(params, "name", ["given_name", "family_name"])
    Person.remove_root_level_fields(params, "address", ["street_address", "postal_code", "locality"])      
    PersonConnection.put_attributes(params, self.id, cookie)
  end
  
  def self.remove_root_level_fields(params, field_type, fields)
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
      person_hash = Person.cache_fetch(id,cookie)
      #person_hash = PersonConnection.get_person(self.id, cookie)
    rescue RestClient::Unauthorized => e
      cookie = Session.updateKassiCookie
      person_hash = PersonConnection.get_person(self.id, cookie)
      #Rails.cache.write("person_hash.#{id}_asked_with_cookie.#{cookie}",  person_hash, :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME)
      cache_write(person_hash,id,cookie)
    rescue RestClient::ResourceNotFound => e
      #Could not find person with that id in COS Database!
      return nil
    end
    
    return person_hash["entry"]
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
  
  def leave_group(group_id, cookie)
    PersonConnection.leave_group(self.id, group_id, cookie)
  end
  
  # Takes a person hash from COS and extracts ids from it
  # into an array.
  def self.get_person_ids(person_hash)
    return nil if person_hash.nil?
    person_hash["entry"].collect { |person| person["id"] }
  end
  
  # A query to get the Kassi events if they are only displayed after
  # the return time of the reservation related to the event has passed.
  # NOTE: not currently used, since behaviore described above is not needed
  def get_kassi_events
    query = "
      SELECT DISTINCT kassi_events.id, kassi_events.realizer_id, kassi_events.receiver_id, 
                      kassi_events.eventable_id, kassi_events.eventable_type, kassi_events.created_at 
      FROM kassi_events, conversations, kassi_events_people
      WHERE kassi_events.id = kassi_events_people.kassi_event_id
      AND kassi_events_people.person_id = '#{id}'
      AND (kassi_events.eventable_type <> 'Reservation'
      OR (kassi_events.eventable_id = conversations.id
          AND conversations.return_time < '#{DateTime.now.utc}'))
      ORDER BY id DESC
    "
    KassiEvent.find_by_sql(query)
  end
  
  private
  
  # This method constructs a key to be used in caching.
  # Important thing is that cache contains peoples profiles, but
  # the contents stored may be different, depending on who's asking.
  # There for the key contains person_id and a hash calculated from cookie.
  # (Cookie is different for each asker.)
  def self.cache_key(id,cookie)
    "person_hash.#{id}_asked_by.#{cookie.hash}"
  end
  
  #Methods to simplify the cache access
  
  def self.cache_fetch(id,cookie)
    Rails.cache.fetch(cache_key(id,cookie), :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME) {PersonConnection.get_person(id, cookie)}
  end
  
  def self.cache_write(person_hash,id,cookie)
    Rails.cache.write(cache_key(id,cookie), person_hash, :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME)
  end
    
  def self.cache_delete(id,cookie)
    Rails.cache.delete(cache_key(id,cookie))
  end
end
