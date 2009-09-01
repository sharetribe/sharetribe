require 'rest_client'

module RestHelper

  def self.request_with_try_again(method, url, params=nil, headers=nil)
    raise ArgumentError.new("Unrecognized method #{method} for rest call") unless ([:get, :post, :delete, :put].include?(method))
    
    begin
      response = call(method, url, params, headers)
    rescue RestClient::RequestTimeout => e
      # In case of timeout, try once again
      Rails.logger.error { "Rest-client reported a timeout when calling #{method} for #{url} with params #{params}. Trying again..." }
      response = call(method, url, params, headers)
    end
    
    return JSON.parse(response)
  end
  
  private 
  
  def self.call(method, url, params=nil, headers=nil)
    response = case method    
      when :get, :delete then RestClient.try(method, url, params)
      when :post, :put   then RestClient.try(method, url, params, headers) 
    end
    
    return response
  end
end
