# This module is used to access the SMS API FROM TeliaSonera 
# (http://developer.medialab.sonera.fi/info/index.php/APIs)
# If willing to use some other SMS service provider
# This module can be replaced with a different one.

module SmsHelper
  class SmsParseError < StandardError
  end
  
  if APP_CONFIG.use_sms
    def self.send(message, number)
    
      # clean up the number (for some reason putting ')' and '(' in regexp didn't work, so using 3 gsubs for cleaning)
      # also change numbers starting with 0 to start with finnish 358
      number = number.gsub(/[\s\+-]/, "").gsub("(", "").gsub(")","").gsub(/^0/, "358")
    
      user_key = log_in_to_api
      sms_uri = "http://api.medialab.sonera.fi/iw/rest/messaging/sms?serviceKey=#{APP_CONFIG.sms_service_key}&userKey=#{user_key}"
      sms_text = '{"sms":{"@messageClass" : "1","@anonymous" : "true","address" : "' + number +'", "message" : "' + message + '" }}'
    
      begin
        Rails.logger.info  "Sending sms message: '#{message}' to #{number}"
        response = RestClient.post(sms_uri, sms_text, :content_type => 'application/json')
      rescue Exception => e
        # HoptoadNotifier.notify(
        #            :error_class => "Special Error", 
        #            :error_message => "Special Error: #{e.message}", 
        #          )
        Rails.logger.error { "Sending message failed: #{e.inspect}, #{e.response}" }
      end
    end
  
    def self.get_messages
  
      user_key = log_in_to_api

      # get all messages in the inbox
      response = RestClient.get("http://api.medialab.sonera.fi/iw/rest/receive/#{APP_CONFIG.sms_username}/#{APP_CONFIG.sms_receiver_id}?userKey=#{user_key}&serviceKey=#{APP_CONFIG.sms_service_key}", {:Accept => 'application/json'})
    
      message_strings = JSON.parse(response)["receiver"]["messages"]
      return [] if message_strings.nil? # no messages in inbox
      messages = []
    
      if message_strings.class == Hash
        # if only one message in the inbox (the usual case) wrap in array
        # because then same iteration works also in cases with many messages
        message_strings = [message_strings]
      end
    
      message_strings.each do |message|
        messages.push(parse(message))
      end
    
      return messages
    end
  
    def self.delete_messages(id_array)
      user_key = log_in_to_api
    
      id_array.each do |sms_id|
        response = RestClient.delete("http://api.medialab.sonera.fi/iw/rest/receive/#{APP_CONFIG.sms_username}/#{APP_CONFIG.sms_receiver_id}/#{sms_id}?userKey=#{user_key}&serviceKey=#{APP_CONFIG.sms_service_key}", {:Accept => 'application/json'}) unless sms_id.blank?
      end
    
    
    end
  
    def self.parse(message)
      details = {:phone_number => message["msisdn"], :original_text => message["message"], :original_id => message["@id"]}    
      parts = message["message"].split(" ")
        
      Rails.logger.info "Received a sms message and divided it to #{parts}"

        
      case parts[0]
      when /#{all_translations("sms.rideshare")}/i
        details[:category] = "rideshare"
        
        raise_sms_parse_error(message) if parts.count < 5
        
        details[:listing_type] = case parts[1]
        when /#{all_translations("sms.offer")}/i
          "offer"
        when /#{all_translations("sms.request")}/i
          "request"
        else
          raise_sms_parse_error(message)
        end

        details[:origin] = parts[2]
        details[:destination] = parts[3]

        time =  Time.zone.parse(parts[4]).to_datetime
        if time < DateTime.now && time > 1.days.ago
          # if only clock time is given and it's earlier than now,
          # probably the time means tomorrow.
          time += 1.days
        end
        details[:valid_until] = time
        details[:description] = parts[5..(parts.length-1)].join(" ")
       
      when /#{all_translations("sms.pay")}/i
        details[:category] = "pay"
        details[:receiver] = parts[1]
        amount = parts[2]
        raise_sms_parse_error(message) unless amount =~ /^\d+(\.|,)?\d*e?$/i
        amount.gsub!(/e/i,"")
        amount.gsub!(",",".")
        details[:amount] = amount
        
      else
        raise_sms_parse_error(message)
      end
      
      return details  
      
    end
  
    # returns all translations for given key, joined with a |
    # This is useful in sms parsing as we don't know the language of the sms
    def self.all_translations(key)
      combination = ""
      I18n.available_locales.each do |loc|
        combination += "|" unless combination.blank?
        combination += I18n.t(key, :locale => loc)
      end
      return combination
    end
  
    private
  
    def self.raise_sms_parse_error(message, error_message=nil)
      error = SmsController::SmsParseError.new(error_message.nil? ? I18n.t("sms.parsing_error") : error_message)
      error.sms_id = message["@id"]
      error.sms_text = message["message"]
      error.sms_from = message["msisdn"]
      raise error  
    end
  
    def self.log_in_to_api
      # Log in to sms API
      response = RestClient.get("http://api.medialab.sonera.fi/iw/rest/login?username=#{APP_CONFIG.sms_username}&password=#{APP_CONFIG.sms_password}&serviceKey=#{APP_CONFIG.sms_service_key}")
      user_key = response[/<userKey>(.+)<\/userKey>/, 1]
    end
  end
end
