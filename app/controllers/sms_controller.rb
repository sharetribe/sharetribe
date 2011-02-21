class SmsController < ApplicationController
  class SmsParseError < StandardError
    attr_accessor :sms_id
    attr_accessor :sms_text
    attr_accessor :sms_from
  end
  
  def show
    message_arrived
  end
  
  def message_arrived
    render :text => "SMS feature not in use" and return unless APP_CONFIG.use_sms
    
    begin
      messages = SmsHelper.get_messages
    rescue SmsController::SmsParseError => e
      # Some sms cannot be parsed
      # -> delete from inbox and return with error
      logger.info "Received a message: \"#{e.sms_text}\" from #{e.sms_from}, but enountered error (#{e.message}) so deleted it."
      SmsHelper.delete_messages [e.sms_id]
      render :text => e.message and return
    end
    
    if messages.empty?
      render :text => "Virhe viestin vastaanotossa, yritä uudestaan. (inbox empty) Error in receiving the message, please try again." and return 
    end
        
    messages.each do |message|
      
      # search the user in ASI
      author_hash = Person.search_by_phone_number(message[:phone_number])
      if author_hash.nil?
        delete_message_and_render_error(message, 
          "Varmista että puhelinnumerosi on tallennettu profiiliisi ja yritä uudestaan. (#{message[:phone_number]}) Make sure that phone number is stored in your profile.") and return
      end
      
      # Make sure that the person is also in Kassi Database
      author = Person.find_by_id(author_hash["id"])
      if author.nil?
        delete_message_and_render_error(message, 
          "Kirjaudu Kassiin ainakin kerran, ennen kuin lähetät viestiä. You have to log in Kassi at least once before sumbiting an SMS.") and return
      end
      
      # At this point we can know the preferred language of the user.
      I18n.locale = author.locale.to_sym || :fi
      
      # Create the listing
      begin
        case message[:category]
        when "rideshare"
          listing_details = message.except(:phone_number, :original_text, :original_id)
          listing_details[:author_id] = author.id
          @listing = Listing.create!(listing_details)
          logger.info "Received a message: \"#{message["message"]}\" from #{message[:phone_number]}, and created a listing (id: #{@listing.id}) from it."
          
          # Listing created succesfully, delete the message from inbox
          SmsHelper.delete_messages [message[:original_id]]
        when "pay"
          # When operator payment API exists,
          # At this point we should check the stored info about the payment 
          # suggestion messages sent and find the a recent one that suggested a ride
          # for this day or yesterday and where the drivers name matches to the name in the message
          
          # And then should call the payment API to make the actual payment
          
          # Payment delivered succesfully, delete the message from inbox
          SmsHelper.delete_messages [message[:original_id]]  
            
          render :text => t("sms.payment_delivered", :receiver => message[:receiver], :amount => message[:amount], :amount_plus_commission => sprintf('%.2f', (message[:amount].to_f * 1.05))) and return
        else
          delete_message_and_render_error(message, t("sms.category_not_supported")) and return
        end
      rescue Exception => e
        delete_message_and_render_error(message, 
         "Virhe tapahtui. Error occurred: #{e.message}")  and return
      end
    end
    
    render :text => t("sms.listing_created")
  end

  def delete_message_and_render_error(message, error_message)
    logger.info "Received a message: \"#{message[:original_text]}\" from #{message[:phone_number]}, but enountered error (#{error_message}) so deleted it."
    SmsHelper.delete_messages [message[:original_id]]
    render :text => error_message
    
  end
end
