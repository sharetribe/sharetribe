require 'rest_client'

module RestHelper

  def self.event_id
    Thread.current[:event_id]
  end

  def self.event_id=(id)
    Thread.current[:event_id] = id
  end
  
  def self.get(url, headers=nil)
    make_request(:get, url, headers)
  end
  
  def self.delete(url, headers=nil)
    make_request(:delete, url, headers)
  end
  
  def self.post(url, params=nil, headers=nil)
    make_request(:post, url, params, headers)
  end
  
  def self.put(url, params=nil, headers=nil)
    make_request(:put, url, params, headers)
  end

  def self.make_request(method, url, params=nil, headers=nil)
    raise ArgumentError.new("Unrecognized method #{method} for rest call") unless ([:get, :post, :delete, :put].include?(method))
    
    begin
      response = call(method, url, params, headers)
    rescue RestClient::RequestTimeout => e
      # In case of timeout, try once again
      Rails.logger.error { "Rest-client reported a timeout when calling #{method} for #{url} with params #{params}. Trying again..." }
      response = call(method, url, params, headers)
    end
    
    return JSON.parse(response.body)
  end
  
  private 
  
  def self.call(method, url, params=nil, headers=nil)
    #puts "Event ID: #{event_id}"
    response = case method    
      when :get, :delete
        if (event_id)
          if url.match(/\?/)
            addition = "&event_id=#{event_id}"
          else
            addition = "?event_id=#{event_id}"
          end
          url += addition
          #puts "URL AFTER ADDITION #{url}"
        end
        RestClient.try(method, url, params)
      when :post, :put
        if (event_id)
          params.merge!(:event_id => event_id)
          #puts "PARAMS AFTER MERGE #{params.inspect}"
        end
        RestClient.try(method, url, params, headers) 
    end
    
    return response
  end
end
