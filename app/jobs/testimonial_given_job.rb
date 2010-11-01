class TestimonialGivenJob < Struct.new(:conversation_id, :host) 
  
  def perform
    conversation = Conversation.find(conversation_id)
    conversation.participants.each do |person|
      transaction_count = person.authored_testimonials.count + person.received_testimonials.count
      case transaction_count
      when 1
        person.give_badge("first_transaction", host)
      end
    end  
  end
  
end