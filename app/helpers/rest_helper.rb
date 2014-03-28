require 'rest_client'
require "benchmark"

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

  def self.make_request(method, url, params=nil, headers=nil, return_full_response=false)

    cookie_used_for_call = nil #this is used if getting unauthorized response
    if method.to_sym == :post || method.to_sym == :put
      cookie_used_for_call = headers[:cookies] if headers
    else # with get and delete the headers are the third param here (params)
       cookie_used_for_call = params[:cookies] if params
    end

    raise ArgumentError.new("Unrecognized method #{method} for rest call") unless ([:get, :post, :delete, :put].include?(method))

    begin
      response = call(method, url, params, headers)

    rescue RestClient::RequestTimeout => e
      # In case of timeout, try once again
      Rails.logger.error { "Rest-client reported a timeout when calling #{method} for #{url} with params #{params}. Trying again..." }
      response = call(method, url, params, headers)

    rescue RestClient::Unauthorized => u
      Rails.logger.error { "Rest-client unauthorized when calling #{method} for #{url}."}

      # if the call was made with Sharetribe-cookie, try renewing it
      if (cookie_used_for_call == Session.kassi_cookie)
         Rails.logger.info "Renewing Sharetribe-cookie and trying again..."
         new_cookie = Session.update_kassi_cookie
         if method.to_sym == :get || method.to_sym == :delete
           params.merge!({:cookies => new_cookie})
         else
           headers.merge!({:cookies => new_cookie})
         end
         response = call(method, url, params, headers)
      else
        # Logged in as user, but the session has expired or is otherwise unvalid
        # this is handled in application_controller
        Rails.logger.info "Expired cookie (unauthorized) was for user-session. Logging out and redirecting to root_path"
        raise u
      end
    end

    unless return_full_response
      return JSON.parse(response.body)
    else
      return [JSON.parse(response.body), response]
    end
  end

  private

  def self.call(method, url, params=nil, headers=nil)

    response = nil
    time = Benchmark.realtime do
      response = case method
        when :get, :delete
          if (event_id)
            if url.match(/\?/)
              addition = "&event_id=#{event_id}"
            else
              addition = "?event_id=#{event_id}"
            end
            url += addition
          end
          RestClient.try(method, url, params)
        when :post, :put
          if (event_id)
            params.merge!(:event_id => event_id)
          end
          RestClient.try(method, url, params, headers)
      end
    end
    Rails.logger.info "ASI Call: (#{(time*1000).round}ms) #{method} #{url} (#{Time.now})"
    return response

  end
end
