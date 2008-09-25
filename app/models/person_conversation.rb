class PersonConversation < ActiveRecord::Base
  
  belongs_to :conversation
  belongs_to :person
  
  validates_presence_of :person_id, :conversation_id

end
