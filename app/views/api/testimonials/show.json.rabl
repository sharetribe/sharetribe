object @testimonial
attributes :grade, :text, :receiver_id, :created_at

node  :conversation_id do |testimonial|
  testimonial.participation.conversation.id
end

child :author => :author do 
  extends "api/people/small_info"
end
