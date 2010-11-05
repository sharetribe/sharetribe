class TestimonialGivenJob < Struct.new(:testimonial_id, :host) 
  
  def perform
    testimonial = Testimonial.find(testimonial_id)
    testimonial.notify_receiver(host)
    testimonial.participation.conversation.participants.each do |person|
      transaction_count = person.authored_testimonials.count + person.received_testimonials.count
      case transaction_count
      when 1
        person.give_badge("first_transaction", host)
      end
    end  
  end
  
end