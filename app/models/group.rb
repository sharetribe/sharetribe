require 'json'

class Group < ActiveRecord::Base
  
  attr_accessor :guid
  
  class GroupConnection < ActiveResource::Base
    # This is an inner class to handle remote connection to COS database where the actual information
    # of group model is stored. This is subclass of ActiveResource so it includes some automatic
    # functionality to access REST interface.
    #
    # In practice we use here connection.post/get/put/delete and the URL and Parameters as described
    # in COS documentation at #{COS_URL}

    self.site = COS_URL
    self.format = :json 
    self.timeout = COS_TIMEOUT
    self.element_name = "groups"
    self.collection_name = "groups"
    
    def self.get_public_groups(cookie)
      return fix_alphabets(connection.get("#{prefix}#{element_name}/@public", {"Cookie" => cookie }))
    end
    
    def self.get_group(id, cookie)
      return fix_alphabets(connection.get("#{prefix}#{element_name}/#{id}", {"Cookie" => cookie }))
    end
    
    def self.get_members(id, cookie)
      return fix_alphabets(connection.get("#{prefix}#{element_name}/#{id}/@members", {"Cookie" => cookie }))
    end
    
    def self.create_group(params, cookie)
      creating_headers = {"Cookie" => cookie}
      response = connection.post("#{prefix}#{element_name}", params.to_json, creating_headers)
    end
    
    def self.put_attributes(params, id, cookie)
      connection.put("#{prefix}#{element_name}/#{id}/@self",{:group => params}.to_json, {"Cookie" => cookie} )   
    end
    
    #fixes utf8 letters
    def self.fix_alphabets(json_hash)
      #the parameter must be a hash that is decoded from JSON by activeResource messing up umlaut letters
      JSON.parse(json_hash.to_json.gsub(/\\\\u/,'\\u'))
    end
    
  end

  def self.create(params, cookie)
    if (cookie)
      # create to Common Services
      response = GroupConnection.create_group(params, cookie)
      #pick id from the response (same id in kassi and COS DBs)
      params[:id] = response.body[/"id":"([^"]+)"/, 1]
      puts "Iidee: " + response.body + "loppuu tähän" + params[:id]
      #create locally with less attributes
      super(params.except(:title, :description, :type))
    else
      # create given group ids to kassi db
      params.each do |param|
        super(param)
      end  
      # TODO: should work like this but doesn't
      # super(params)
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
  
  # Gets all groups from COS and adds to Kassi db all that are not already there.
  def self.add_new_public_groups_to_kassi_db(cookie=nil)
    cookie = Session.kassiCookie if cookie.nil?
    group_ids_not_in_kassi = []
    cos_group_ids = Group.get_group_ids(GroupConnection.get_public_groups(cookie))
    kassi_group_ids = Group.find(:all, :select => "id").collect(&:id)
    cos_group_ids.each do |id|
      unless kassi_group_ids.include?(id)
        group_ids_not_in_kassi << { :id => id }
      end
    end
    Group.create(group_ids_not_in_kassi, nil)
  end
  
  def title(cookie=nil)
    return "" if new_record?
    group_hash = get_group_hash(cookie)
    return "Not found!" if group_hash.nil?
    return group_hash["group"]["title"]
  end
  
  def set_title(title, cookie)
    update_attributes({:title => title}, cookie)
  end
  
  def description(cookie=nil)
    return "" if new_record?
    group_hash = get_group_hash(cookie)
    return "Not found!" if group_hash.nil?
    return group_hash["group"]["description"]
  end
  
  def set_description(description, cookie)
    update_attributes({:description => description}, cookie)
  end
  
  def set_type(type, cookie)
    update_attributes({:type => type}, cookie)
  end
  
  def members(cookie)
    Person.find_kassi_users_by_ids(get_member_ids(cookie))
  end
  
  def get_member_ids(cookie)
    Person.get_person_ids(get_members(cookie))
  end
  
  def update_attributes(params, cookie)
    GroupConnection.put_attributes(params, self.id, cookie)
  end

  # Returns a hash from COS containing attributes of a group
  def get_group_hash(cookie=nil)
    cookie = Session.kassiCookie if cookie.nil?
    
    begin
      group_hash = GroupConnection.get_group(self.id, cookie)
    rescue ActiveResource::UnauthorizedAccess => e
      cookie = Session.updateKassiCookie
      group_hash = GroupConnection.get_group(self.id, cookie)
    rescue ActiveResource::ResourceNotFound => e
      #Could not find group with that id in COS Database!
      return nil
    end
    
    return group_hash
  end
  
  # Retrieves members of this group from COS
  def get_members(cookie)
    
    begin
      member_hash = GroupConnection.get_members(self.id, cookie)
    rescue ActiveResource::ResourceNotFound => e
      #Could not find group with that id in COS Database!
      return nil
    end
    
    return member_hash
  end
  
  def is_member?(person, cookie)
    get_member_ids(cookie).include?(person.id) 
  end
  
  # Takes a group hash from COS and extracts ids from it
  # into an array.
  def self.get_group_ids(group_hash)
    group_hash["entry"].collect { |group| group["group"]["id"] }
  end

end