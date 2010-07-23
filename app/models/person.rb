require 'json'
require 'rest_client'
require 'httpclient'

class Person < ActiveRecord::Base
  
  include ErrorsHelper
  
  PERSON_HASH_CACHE_EXPIRE_TIME = 15
  PERSON_NAME_CACHE_EXPIRE_TIME = 3.hours
    
  attr_accessor :guid, :password, :password2, :username, :email, :form_username, :form_given_name, :form_family_name, :form_password, :form_password2, :form_email, :consent
  
  attr_protected :is_admin

  has_many :listings, :dependent => :destroy, :foreign_key => "author_id"

  # has_many :feedbacks
  # 
  #   
  #   has_many :items, :foreign_key => "owner_id", :dependent => :destroy
  #            
  #   has_many :disabled_items, 
  #            :class_name => "Item",
  #            :foreign_key => "owner_id",
  #            :conditions => "status = 'disabled'",
  #            :order => "title",
  #            :dependent => :destroy 
  #   
  #   has_many :disabled_favors, 
  #            :class_name => "Favor",
  #            :foreign_key => "owner_id", 
  #            :conditions => "status = 'disabled'",
  #            :order => "title",
  #            :dependent => :destroy 
  #   
  #   has_many :favors, :foreign_key => "owner_id", :dependent => :destroy 
  # 
  #   has_many :person_interesting_listings, :dependent => :destroy 
  #   has_many :interesting_listings, 
  #            :through => :person_interesting_listings, 
  #            :source => :listing
  #            
  #   has_many :person_conversations, :dependent => :destroy 
  #   has_many :conversations, 
  #            :through => :person_conversations, 
  #            :source => :conversation
  #   
  #   has_many :received_comments, 
  #            :class_name => "PersonComment", 
  #            :foreign_key => "target_person_id",
  #            :dependent => :destroy,
  #            :order => "id DESC" 
  #            
  #   has_many :kassi_event_participations, :dependent => :destroy
  #   has_many :kassi_events, 
  #            :through => :kassi_event_participations, 
  #            :source => :kassi_event,
  #            :conditions => "pending = 0"
  #   has_many :own_kassi_events, 
  #            :through => :kassi_event_participations, 
  #            :source => :kassi_event
  #            
  #   has_one :settings, :dependent => :destroy
  #   
  #   has_and_belongs_to_many :followed_listings, :class_name => "Listing", :join_table => "listing_followers"        
  
  class PersonConnection < ActiveRecord::Base
    # This is an inner class to handle remote connection to ASI database where the actual information
    # of person model is stored. This is subclass of ActiveResource so it includes some automatic
    # functionality to access REST interface.
    #
    # In practise we use here connection.post/get/put/delete and the URL and Parameters as described
    # in ASI documentation at #{APP_CONFIG.asi_url}
     
    include RestHelper
    
    def self.create_person(params, cookie)
      CacheHelper.update_people_last_changed
      return RestHelper.make_request(:post, "#{APP_CONFIG.asi_url}/people", params, {:cookies => cookie})
    end
    
    def self.get_person(id, cookie)
      return RestHelper.make_request(:get, "#{APP_CONFIG.asi_url}/people/#{id}/@self", {:cookies => cookie})
    end
    
    def self.search(query, cookie)
      escaped_query = ApplicationHelper.escape_for_url(query)
      return RestHelper.make_request(:get,"#{APP_CONFIG.asi_url}/people?search=#{escaped_query}", {:cookies => cookie})
      # return JSON.parse(RestClient.get("#{APP_CONFIG.asi_url}/people?search=#{escaped_query}", {:cookies =
    end
    
    def self.get_friends(id, cookie)
      #JSON.parse(RestClient.get("#{APP_CONFIG.asi_url}/people/#{id}/@friends", {:cookies => cookie}))
      return RestHelper.make_request(:get, "#{APP_CONFIG.asi_url}/people/#{id}/@friends", {:cookies => cookie})
    end
    
    def self.get_pending_friend_requests(id, cookie)
      return RestHelper.make_request(:get, "#{APP_CONFIG.asi_url}/people/#{id}/@pending_friend_requests", {:cookies => cookie})
      #return JSON.parse(RestClient.get("#{APP_CONFIG.asi_url}/people/#{id}/@pending_friend_requests", {:cookies => cookie}))
    end
    
    def self.put_attributes(params, id, cookie)
      # information changes, clear cache
      parent.cache_delete(id,cookie)
      CacheHelper.update_people_last_changed
      return RestHelper.make_request(:put, "#{APP_CONFIG.asi_url}/people/#{id}/@self", {:person => params}, {:cookies => cookie})
      #JSON.parse(RestClient.put("#{APP_CONFIG.asi_url}/people/#{id}/@self", {:person => params}, {:cookies => cookie})) 
    end
    
    def self.update_avatar(image, id, cookie)
      response = HTTPClient.post("#{APP_CONFIG.asi_url}/people/#{id}/@avatar", { :file => image }, {'Cookie' => cookie})
      if response.status != 200
        raise Exception.new(JSON.parse(response.body.content)["messages"])
      end
    end
    
    def self.add_as_friend(friend_id, id, cookie)
      parent.cache_delete(id,cookie)
      #Rails.cache.delete("person_hash.#{friend_id}_asked_with_cookie.#{cookie}")
      parent.cache_delete(friend_id,cookie)
      CacheHelper.update_people_last_changed
      return RestHelper.make_request(:post, "#{APP_CONFIG.asi_url}/people/#{id}/@friends", {:friend_id => friend_id}, {:cookies => cookie})
      #return RestClient.post("#{APP_CONFIG.asi_url}/people/#{id}/@friends", {:friend_id => friend_id}, {:cookies => cookie})
    end
    
    def self.remove_from_friends(friend_id, id, cookie)
      parent.cache_delete(id,cookie)
      #Rails.cache.delete("person_hash.#{friend_id}_asked_with_cookie.#{cookie}")
      parent.cache_delete(friend_id,cookie)
      CacheHelper.update_people_last_changed
      #RestClient.delete("#{APP_CONFIG.asi_url}/people/#{id}/@friends/#{friend_id}", {:cookies => cookie}) 
      return RestHelper.make_request(:delete, "#{APP_CONFIG.asi_url}/people/#{id}/@friends/#{friend_id}", {:cookies => cookie})
    end
    
    def self.remove_pending_friend_request(friend_id, id, cookie)
      parent.cache_delete(id,cookie)
      #Rails.cache.delete("person_hash.#{friend_id}_asked_with_cookie.#{cookie}")
      parent.cache_delete(friend_id,cookie)
      CacheHelper.update_people_last_changed
      # RestClient.delete("#{APP_CONFIG.asi_url}/people/#{id}/@pending_friend_requests/#{friend_id}", {:cookies => cookie})
      return RestHelper.make_request(:delete, "#{APP_CONFIG.asi_url}/people/#{id}/@pending_friend_requests/#{friend_id}", {:cookies => cookie})
    end
    
    def self.get_groups(id, cookie, event_id=nil)
      request_url = "#{APP_CONFIG.asi_url}/people/#{id}/@groups"
      request_url += "?event_id=#{event_id}" if event_id
      #JSON.parse(RestClient.get(request_url, {:cookies => cookie}))
      
      return RestHelper.make_request(:get, request_url, {:cookies => cookie})
    
    end
    
    def self.join_group(id, group_id, cookie)
      CacheHelper.update_groups_last_changed
      #JSON.parse(RestClient.post("#{APP_CONFIG.asi_url}/people/#{id}/@groups", {:group_id => group_id}, {:cookies => cookie}))
      return RestHelper.make_request(:post, "#{APP_CONFIG.asi_url}/people/#{id}/@groups", {:group_id => group_id}, {:cookies => cookie} )
      #response = connection.post("#{prefix}people/#{id}/@groups", { :group_id => group_id }.to_json, {"Cookie" => cookie})
    end
    
    def self.leave_group(id, group_id, cookie)
      CacheHelper.update_groups_last_changed
      #JSON.parse(RestClient.delete("#{APP_CONFIG.asi_url}/people/#{id}/@groups/#{group_id}", {:cookies => cookie}))
      return RestHelper.make_request(:delete, "#{APP_CONFIG.asi_url}/people/#{id}/@groups/#{group_id}", {:cookies => cookie})
      #response = connection.delete("#{prefix}people/#{id}/@groups/#{group_id}", {"Cookie" => cookie})
    end
    
    def self.get_group_admin_status(id, group_id, cookie)
      logger.info "Url: #{APP_CONFIG.asi_url}/people/#{id}/@groups/#{group_id}"
      return RestHelper.make_request(:get, "#{APP_CONFIG.asi_url}/people/#{id}/@groups/#{group_id}", {:cookies => cookie})
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
    params[:id] = response["entry"]["id"]
    
    # Add name information for the person to COS 
    params[:given_name] = params[:given_name].slice(0, 28)
    params[:family_name] = params[:family_name].slice(0, 28)
    Person.remove_root_level_fields(params, "name", ["given_name", "family_name"])  
    PersonConnection.put_attributes(params.except(:username, :email, :password, :password2, :locale), params[:id], cookie)
    
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
    #puts "IN AFTER_INITIALIZE #{self.id} ja #{self.guid}"
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
    # No expire time, because username doesn't change (at least not yet)
    Rails.cache.fetch("person_username/#{self.id}") {username_from_person_hash(cookie)}  
  end
  
  def username_from_person_hash(cookie=nil)
    if new_record?
      return form_username ? form_username : ""
    end
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    return person_hash["username"]
  end
  
  def name_or_username(cookie=nil)
    # First check the person name cache (which is common to al users)
    # If not found use the person_hash cache (which is separate for each asker)
    Rails.cache.fetch("person_name/#{self.id}", :expires_in => PERSON_NAME_CACHE_EXPIRE_TIME) {name_or_username_from_person_hash(cookie)}
  end
      
  def name_or_username_from_person_hash(cookie=nil)
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
    update_attributes({:name => {:given_name => name } }, cookie)
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
  
  def description(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["description"]
  end
  
  def set_description(description, cookie)
    update_attributes({:description => description}, cookie)
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
    group_hash = Rails.cache.fetch(Person.groups_cache_key(id,cookie), :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME) {PersonConnection.get_groups(self.id, cookie, event_id)}
    return group_hash
  end
  
  def update_attributes(params, cookie)
    #Handle name part parameters also if they are in hash root level
    Person.remove_root_level_fields(params, "name", ["given_name", "family_name"])
    Person.remove_root_level_fields(params, "address", ["street_address", "postal_code", "locality"]) 

    if params["name"] || params[:name]
      # If name is going to be changed, expire name cache
      Rails.cache.delete("person_name/#{self.id}")
    end
         
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
      Person.cache_write(person_hash,id,cookie)
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
    Rails.cache.delete(Person.groups_cache_key(id,cookie))
  end
  
  def leave_group(group_id, cookie)
    PersonConnection.leave_group(self.id, group_id, cookie)
    Rails.cache.delete(Person.groups_cache_key(id,cookie))
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
      AND kassi_events.pending = 0
      AND (kassi_events.eventable_type <> 'Reservation'
      OR (kassi_events.eventable_id = conversations.id
          AND conversations.return_time < '#{DateTime.now.utc}'))
      ORDER BY id DESC
    "
    KassiEvent.find_by_sql(query)
  end
  
  # Returns true if the person has admin rights in Kassi.
  def is_admin?
    is_admin == 1
  end
  
  # Returns the number of kassi events of this person that
  # he has not yet commented on.
  def uncommented_kassi_event_count
    query1 = "
      SELECT COUNT(ke.id) - (SELECT COUNT(*) FROM person_comments WHERE author_id = '#{id}')
      FROM kassi_events AS ke, kassi_event_participations AS kep
      WHERE kep.person_id = '#{id}'
      AND kep.kassi_event_id = ke.id
    "
    KassiEvent.count_by_sql(query1)
  end
  
  # Starts following a listing
  def follow(listing)
    followed_listings << listing
  end
  
  # Unfollows a listing
  def unfollow(listing)
    followed_listings.delete(listing)
  end
  
  # Checks if this user is following the given listing
  def is_following?(listing)
    followed_listings.include?(listing)
  end
  
  # Updates the user following status based on the given status
  # for the given listing
  def update_follow_status(listing, status)
    unless id == listing.author.id
      if status
        follow(listing) unless is_following?(listing)
      else
        unfollow(listing) if is_following?(listing)
      end
    end
  end
  
  # Returns true if this person is an admin of the
  # given group
  def is_admin_of?(group, cookie)
    return false unless group.is_member?(self, cookie)
    PersonConnection.get_group_admin_status(id, group.id, cookie)["entry"]["admin_role"]
  end
  
  def create_listing(params)
    listings.create params
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
  
  def self.groups_cache_key(id,cookie)
    "person_groups_hash.#{id}_asked_by.#{cookie.hash}"
  end
  
  
  #Methods to simplify the cache access
  
  def self.cache_fetch(id,cookie)
    #PersonConnection.get_person(id, cookie)  # A line to skip the cache temporarily
    Rails.cache.fetch(cache_key(id,cookie), :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME) {PersonConnection.get_person(id, cookie)}
  end
  
  def self.cache_write(person_hash,id,cookie)
    Rails.cache.write(cache_key(id,cookie), person_hash, :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME)
  end
    
  def self.cache_delete(id,cookie)
    Rails.cache.delete(cache_key(id,cookie))
  end
end
