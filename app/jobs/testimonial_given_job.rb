class TestimonialGivenJob < Struct.new(:testimonial_id, :host) 
  
  def perform
    testimonial = Testimonial.find(testimonial_id)
    testimonial.notify_receiver(host)
    case testimonial.receiver.received_testimonials.count
    when 1
      testimonial.receiver.give_badge("first_transaction", host)
    when 3
      testimonial.receiver.give_badge("active_member_bronze", host)
    when 10
      testimonial.receiver.give_badge("active_member_silver", host)
    when 20
      testimonial.receiver.give_badge("active_member_gold", host)    
    end  
  end
  
end