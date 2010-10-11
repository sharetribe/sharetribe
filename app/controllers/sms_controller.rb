class SmsController < ApplicationController
  def message_arrived
    # Log in to sms API
    response = RestClient.get("http://api.medialab.sonera.fi/iw/rest/login?username=#{APP_CONFIG.sms_username}&password=#{APP_CONFIG.sms_password}&serviceKey=#{APP_CONFIG.sms_service_key}")
    user_key = response[/<userKey>(.+)<\/userKey>/, 1]

    puts user_key
    response = RestClient.get("http://api.medialab.sonera.fi/iw/rest/receive/#{APP_CONFIG.sms_username}/#{APP_CONFIG.sms_receiver_id}?userKey=#{user_key}&serviceKey=#{APP_CONFIG.sms_service_key}", {:Accept => 'application/json'})
    
    puts response
    
    
    render :text => "Kiitos viestistä! Thank you for the message!"
  end

end
