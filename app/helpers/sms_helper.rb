# This module is used to access the SMS API FROM TeliaSonera 
# (http://developer.medialab.sonera.fi/info/index.php/APIs)
# If willing to use some other SMS service provider
# This module can be replaced with a different one.

module SmsHelper
  class SmsParseError < StandardError
  end
  
  def self.send
    
  end
  
  def self.get_messages
  
    user_key = log_in_to_api

    # get all messages in the inbox
    response = RestClient.get("http://api.medialab.sonera.fi/iw/rest/receive/#{APP_CONFIG.sms_username}/#{APP_CONFIG.sms_receiver_id}?userKey=#{user_key}&serviceKey=#{APP_CONFIG.sms_service_key}", {:Accept => 'application/json'})
    
    puts response
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
      #puts message_hash.to_yaml
    end
    
    return messages
  end
  
  def self.delete_messages(id_array)
    user_key = log_in_to_api
    
    id_array.each do |sms_id|
      response = RestClient.delete("http://api.medialab.sonera.fi/iw/rest/receive/#{APP_CONFIG.sms_username}/#{APP_CONFIG.sms_receiver_id}/#{sms_id}?userKey=#{user_key}&serviceKey=#{APP_CONFIG.sms_service_key}", {:Accept => 'application/json'}) unless sms_id.blank?
      puts response
    end
    
    
  end
  
  def self.parse(message)
    details = {:phone_number => message["msisdn"], :original_text => message["message"], :original_id => message["@id"]}    
    parts = message["message"].split
    
    details[:category] = case parts[0]
    when /#{I18n.t("sms.rideshare")}/ 
      "rideshare"
    else
      raise_sms_parse_error(message)
    end
    
    details[:listing_type] = case parts[1]
    when /#{I18n.t("sms.offer")}/
      "offer"
    when /#{I18n.t("sms.request")}/
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
    
    return details
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
