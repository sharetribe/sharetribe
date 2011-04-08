# This is a separate class to handle remote connection to ASI database where the
# actual information of person model is stored.
# 
# In practise we use the REST interface as described in ASI documentation at
# #{APP_CONFIG.asi_url}

class PersonConnection 

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
   end
   
   def self.search_by_phone_number(number, cookie)
      escaped_query = ApplicationHelper.escape_for_url(number.to_s)
      return RestHelper.make_request(:get,"#{APP_CONFIG.asi_url}/people?phone_number=#{escaped_query}", {:cookies => cookie})
    end
   
   def self.get_friends(id, cookie)
     return RestHelper.make_request(:get, "#{APP_CONFIG.asi_url}/people/#{id}/@friends", {:cookies => cookie})
   end
   
   def self.get_pending_friend_requests(id, cookie)
     return RestHelper.make_request(:get, "#{APP_CONFIG.asi_url}/people/#{id}/@pending_friend_requests", {:cookies => cookie})
   end
   
   def self.put_attributes(params, id, cookie)
     # information changes, clear cache
     Person.cache_delete(id,cookie)
     CacheHelper.update_people_last_changed
     return RestHelper.make_request(:put, "#{APP_CONFIG.asi_url}/people/#{id}/@self", {:person => params}, {:cookies => cookie})
   end
   
   def self.update_avatar(image, id, cookie)
     # Transform cookie to a string with "=" for HTTPClient
     cookie = "#{cookie.keys[0]}=#{cookie.values[0]}"
     
     response = HTTPClient.post("#{APP_CONFIG.asi_url}/people/#{id}/@avatar", { :file => image }, {'Cookie' => cookie})
     if response.status != 200
       raise Exception.new(JSON.parse(response.body.content)["messages"])
     end
   end
   
   def self.add_as_friend(friend_id, id, cookie)
     Person.cache_delete(id,cookie)
     Person.cache_delete(friend_id,cookie)
     CacheHelper.update_people_last_changed
     return RestHelper.make_request(:post, "#{APP_CONFIG.asi_url}/people/#{id}/@friends", {:friend_id => friend_id}, {:cookies => cookie})
   end
   
   def self.remove_from_friends(friend_id, id, cookie)
     Person.cache_delete(id,cookie)
     Person.cache_delete(friend_id,cookie)
     CacheHelper.update_people_last_changed
     return RestHelper.make_request(:delete, "#{APP_CONFIG.asi_url}/people/#{id}/@friends/#{friend_id}", {:cookies => cookie})
   end
   
   def self.remove_pending_friend_request(friend_id, id, cookie)
     Person.cache_delete(id,cookie)
     Person.cache_delete(friend_id,cookie)
     CacheHelper.update_people_last_changed
     return RestHelper.make_request(:delete, "#{APP_CONFIG.asi_url}/people/#{id}/@pending_friend_requests/#{friend_id}", {:cookies => cookie})
   end
   
   def self.get_groups(id, cookie, event_id=nil)
     request_url = "#{APP_CONFIG.asi_url}/people/#{id}/@groups"
     request_url += "?event_id=#{event_id}" if event_id
     return RestHelper.make_request(:get, request_url, {:cookies => cookie})
   end
   
   def self.join_group(id, group_id, cookie)
     CacheHelper.update_groups_last_changed
     return RestHelper.make_request(:post, "#{APP_CONFIG.asi_url}/people/#{id}/@groups", {:group_id => group_id}, {:cookies => cookie} )
   end
   
   def self.leave_group(id, group_id, cookie)
     CacheHelper.update_groups_last_changed
     return RestHelper.make_request(:delete, "#{APP_CONFIG.asi_url}/people/#{id}/@groups/#{group_id}", {:cookies => cookie})
   end
   
   def self.get_group_admin_status(id, group_id, cookie)
     return RestHelper.make_request(:get, "#{APP_CONFIG.asi_url}/people/#{id}/@groups/#{group_id}", {:cookies => cookie})
   end
   
   def self.availability(options, cookie)
     query_string = "/people/availability?"
     query_string += "email=#{ApplicationHelper.escape_for_url(options[:email])}&" if options[:email]
     query_string += "username=#{ApplicationHelper.escape_for_url(options[:username])}&" if options[:username]
     return RestHelper.get("#{APP_CONFIG.asi_url}#{query_string}", {:cookies => cookie})
   end
   
 end
