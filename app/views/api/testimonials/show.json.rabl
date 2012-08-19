object @testimonial
attributes :grade, :text, :author_id, :receiver_id, :created_at

node  :conversation_id do |testimonial|
  testimonial.participation.conversation.id
end
