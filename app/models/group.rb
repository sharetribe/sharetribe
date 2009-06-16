require 'json'

class Group < ActiveRecord::Base
  
  attr_accessor :guid, :form_title, :form_description
  
  has_and_belongs_to_many :items
  
  has_and_belongs_to_many :listings
  
  has_and_belongs_to_many :favors, :join_table => "groups_favors"
  
  
  @@element_name = "groups" # in COS
  

  def self.create(params, cookie)
    if (cookie)
      # create to Common Services
      response = create_group(params, cookie)
      #pick id from the response (same id in kassi and COS DBs)
      params[:id] = response["group"]["id"]

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
    cos_group_ids = Group.get_group_ids(get_public_groups(cookie))
    kassi_group_ids = Group.find(:all, :select => "id").collect(&:id)
    cos_group_ids.each do |id|
      unless kassi_group_ids.include?(id)
        group_ids_not_in_kassi << { :id => id }
      end
    end
    Group.create(group_ids_not_in_kassi, nil)
    
    # Do the checking also other way round. Remove any groups from Kassi DB that have been removed from COS
    # This needs to be changed when there are non public groups.
    kassi_group_ids.each do |id|
      unless cos_group_ids.include?(id)
        Group.find(id).destroy
      end
    end
    
  end
  
  def title(cookie=nil)
    if new_record?
      return form_title ? form_title : ""
    end
    begin
      group_hash = get_group_hash(cookie)
    rescue RestClient::ResourceNotFound
      return ""
    end
    return group_hash["group"]["title"]
  end
  
  def set_title(title, cookie)
    update_attributes({:title => title}, cookie)
  end
  
  def description(cookie=nil)
    if new_record?
      return form_description ? form_description : ""
    end
    begin
      group_hash = get_group_hash(cookie)
    rescue RestClient::ResourceNotFound
      return "group not found!"
    end
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
    put_attributes(params, self.id, cookie)
  end

  # Returns a hash from COS containing attributes of a group
  def get_group_hash(cookie=nil)
    cookie = Session.kassiCookie if cookie.nil?
    
    begin
      group_hash = Group.get_group(self.id, cookie)
    rescue RestClient::Unauthorized => e
      cookie = Session.updateKassiCookie
      group_hash = Group.get_group(self.id, cookie)
    rescue RestClient::ResourceNotFound => e
      #Could not find group with that id in COS Database!
      return nil
    end
    
    return group_hash
  end
  
  # Retrieves members of this group from COS
  def get_members(cookie)
    
    begin
      member_hash = Group.get_members(self.id, cookie)
    rescue RestClient::ResourceNotFound => e
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
  
  private
  
  # Class-Methods for COS access
  # In practice we use here connection.post/get/put/delete and the URL and Parameters as described
  # in COS documentation at #{COS_URL}

  def self.get_public_groups(cookie)
    JSON.parse(RestClient.get("#{COS_URL}/#{@@element_name}/@public", {:cookies => cookie}))
  end
  
  def self.get_group(id, cookie)
    JSON.parse(RestClient.get("#{COS_URL}/#{@@element_name}/#{id}", {:cookies => cookie}))
  end
  
  def self.get_members(id, cookie)
    JSON.parse(RestClient.get("#{COS_URL}/#{@@element_name}/#{id}/@members", {:cookies => cookie}))
  end
  
  def self.create_group(params, cookie)
    JSON.parse(RestClient.post("#{COS_URL}/#{@@element_name}", params, {:cookies => cookie}))
  end
  
  def self.put_attributes(params, id, cookie)
    JSON.parse(RestClient.put("#{COS_URL}/#{@@element_name}/#{id}/@self", {:group => params}, {:cookies => cookie}))
  end

end