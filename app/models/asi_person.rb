# This file overrides some methdos of the Person class
# if this Kassi installation uses ASI server to store person data.

# Information is stored in ASI that is accessed via PersonConnection class.
# Because the delays in the http requests, we use some caching to store the
# results of the ASI-requests.

module AsiPerson
  
  PERSON_HASH_CACHE_EXPIRE_TIME = 15.minutes
  PERSON_NAME_CACHE_EXPIRE_TIME = 3.hours
  
  def self.included(base) # :nodoc:
    base.extend ClassMethods
  end


  module ClassMethods
  
  
    def asi_methods_loaded?
      return true
    end
       
    # Create a new person to ASI and Kassi.
    def create(params, cookie, asi_welcome_mail = false)
      # Try to create the person to ASI
      person_hash = {:person => params.slice(:username, :password, :email, :consent), :welcome_email => asi_welcome_mail}
      response = PersonConnection.create_person(person_hash, cookie)

      # Pick id from the response (same id in kassi and ASI DBs)
      params[:id] = response["entry"]["id"]

      # Because ASI now associates the used cookie to a session for the newly created user
      # Change the KassiCookie to nil if it was used (because now it is no more an app-only cookie) 
      Session.update_kassi_cookie   if  (cookie == Session.kassi_cookie)    

      # Add name information for the person to ASI 
      params["given_name"] = params["given_name"].slice(0, 28)
      params["family_name"] = params["family_name"].slice(0, 28)
      Person.remove_root_level_fields(params, "name", ["given_name", "family_name"])  
      PersonConnection.put_attributes(params.except(:username, :email, :password, :password2, :locale, :terms, :id, :test_group_number, :consent, :confirmed_at, :show_real_name_to_other_users), params[:id], cookie)
      # Create locally with less attributes 
      super(params.except(:username, :email, "name", :terms, :consent, :password))
    end
    
    # Creates a record to local DB with given id
    # Should be used only with ids that exist also in ASI
    def add_to_kassi_db(id)
      person = Person.new({:id => id })

      if person.save!
        return person
      else
        return nil
        logger.error { "Error storing person to Kassi DB with ID: #{id}" }
      end
    end
    
    def search(query)
      cookie = Session.kassi_cookie
      begin
        person_hash = PersonConnection.search(query, cookie)
      rescue RestClient::ResourceNotFound => e
        #Could not find person with that id in ASI Database!
        return nil
      end  
      return person_hash
    end

    def search_by_phone_number(number)
      cookie = Session.kassi_cookie
      begin
        person_hash = PersonConnection.search_by_phone_number(number, cookie)
      rescue RestClient::ResourceNotFound => e
        #Could not find person with that id in ASI Database!
        return nil
      end  
      return person_hash["entry"][0]
    end

    def username_available?(username, cookie=Session.kassi_cookie)
      resp = PersonConnection.availability({:username => username}, cookie)
      if resp["entry"] && resp["entry"][0]["username"] && resp["entry"][0]["username"] == "unavailable"
        return false
      else
        return true
      end
    end

    def email_available?(email, cookie=Session.kassi_cookie)
      resp = PersonConnection.availability({:email => email}, cookie)
      if resp["entry"] && resp["entry"][0]["email"] && resp["entry"][0]["email"] == "unavailable"
        return false
      else
        return true
      end
    end
    
    # Takes a person hash from ASI and extracts ids from it
    # into an array.
    def get_person_ids(person_hash)
      return nil if person_hash.nil?
      person_hash["entry"].collect { |person| person["id"] }
    end

    # Methods to simplify the cache access
    def cache_fetch(id,cookie)
      #PersonConnection.get_person(id, cookie)
      Rails.cache.fetch(cache_key(id,cookie), :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME) {PersonConnection.get_person(id, cookie)}
    end

    def cache_write(person_hash,id,cookie)
      Rails.cache.write(cache_key(id,cookie), person_hash, :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME)
    end

    def cache_delete(id,cookie)
      Rails.cache.delete(cache_key(id,cookie))
    end
    
    # Returns those people who are also kassi users
    def find_kassi_users_by_ids(ids)
      Person.find_by_sql("SELECT * FROM people WHERE id IN ('" + ids.join("', '") + "')")
    end
    
  end #end the module ClassMethods  
  
  # Using GUID string as primary key and id requires little fixing like this
  def initialize(params={})
    self.guid = params[:id] #store GUID to temporary attribute
    super(params)
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
    # First check the person name cache (which is common to all users)
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
    # We rather return the username than blank if no name is set
    return username unless show_real_name_to_other_users
    return name_or_username(cookie)
  end

  def given_name_or_username(cookie=nil)
    if given_name(cookie).blank? || !show_real_name_to_other_users
      return username(cookie)
    else
      return given_name(cookie)
    end
  end

  def given_name(cookie=nil)
    if new_record?
      return form_given_name ? form_given_name : ""
    end

    return Rails.cache.fetch("person_given_name/#{self.id}", :expires_in => PERSON_NAME_CACHE_EXPIRE_TIME) {given_name_from_person_hash(cookie)} 
  end

  def given_name_from_person_hash(cookie)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    unless person_hash["name"].nil? || person_hash["name"]["given_name"].blank?
      return person_hash["name"]["given_name"]
    else
      return ""
    end
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

  def description(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?

    return person_hash["description"]
  end

  def set_description(description, cookie)
    update_attributes({:description => description}, cookie)
  end

  # Returns friends of this person as an array of Person objects
  def friends(cookie)
    Person.find_kassi_users_by_ids(get_friend_ids(cookie))
  end

  # Returns ids of friends (in ASI) of this person
  def get_friend_ids(cookie)
    Person.get_person_ids(get_friends(cookie))
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

  # Retrieves friends of this person from ASI
  def get_friends(cookie)
    friend_hash = PersonConnection.get_friends(self.id, cookie)
    return friend_hash
  end

  def get_friend_requests(cookie)
    request_hash = PersonConnection.get_pending_friend_requests(self.id, cookie)
    return request_hash
  end

  def update_attributes(params, cookie=nil)
    if params[:preferences]
      super(params)
    else  
      #Handle location information
      if self.location 
        #delete location always (it would be better to check for changes)
        self.location.delete
      end
      if params[:location]
        # Set the address part of the location to be similar to what the user wrote.
        # the google_address field will store the longer string for the exact position.
        params[:location][:address] = params[:street_address] if params[:street_address]

        self.location = Location.new(params[:location])
        params[:location].each {|key| params[:location].delete(key)}
        params.delete(:location)
      end
      self.show_real_name_to_other_users = (!params[:show_real_name_to_other_users] && params[:show_real_name_setting_affected]) ? false : true 
      save
      #Handle name part parameters also if they are in hash root level
      Person.remove_root_level_fields(params, "name", ["given_name", "family_name"])
      Person.remove_root_level_fields(params, "address", ["street_address", "postal_code", "locality"]) 

      # Expire the person_hash cache everytime 
      # (we can do this only for the current sessions, so the other users will see the old info for the PERSON_HASH_CACHE_EXPIRE_TIME
      Person.cache_delete(id, cookie)
      Person.cache_delete(id, nil) # also the delete the data fetched and cached without a cookie
      Person.cache_delete(id, Session.kassi_cookie) # also the delete the data fetched and cached with the Kassi's (app only) cookie
      # Expire also the name_caches every time, because it's hard to detecet changes in names if they are changed to empty
      Rails.cache.delete("person_name/#{self.id}")
      Rails.cache.delete("person_given_name/#{self.id}")

      PersonConnection.put_attributes(params.except("password2", "show_real_name_to_other_users", "show_real_name_setting_affected"), self.id, cookie)    
    end
  end

  def update_avatar(file, cookie)
    path = file.path
    original_filename = file.original_filename
    new_path = path.gsub(/\/[^\/]+\Z/, "/#{original_filename}")

    logger.info "path #{path} original_filename #{original_filename} new_path #{new_path}"

    #rename the file to get a suffix and content type accepted by COS
    File.rename(path, new_path)

    file_to_post = File.new(new_path)

    logger.info "FILE TO POST #{file_to_post.path}"
    success = true
    begin 
      PersonConnection.update_avatar(file_to_post, self.id, cookie)
    rescue Exception => e
      logger.info "ASI error: #{e.message.to_s}"
      success = false
      begin
        File.delete(path)
      rescue
        #don't care if fails
      end
    end
    File.delete(new_path) if file_to_post || file_to_post.exists?
    return success
  end

  def get_person_hash(cookie=nil)
    cookie = Session.kassi_cookie if cookie.nil?

    begin
      person_hash = self.class.cache_fetch(id,cookie)
    rescue RestClient::ResourceNotFound => e
      #Could not find person with that id in ASI Database!
      return nil
    end

    return person_hash["entry"]
  end

  def friend_status(cookie = nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    return person_hash["connection"]
  end
end

