class Conversation < ActiveRecord::Base

  belongs_to :listing

  has_many :person_conversations
  has_many :participants, :through => :person_conversations, :source => :person
  
  has_many :messages
  
  validates_presence_of :title
  validates_length_of :title, :within => 2..80
  
  validates_numericality_of :listing_id, :only_integer => true, :allow_nil => true 

  def to_param
    "#{id}_re:#{title.to_s.gsub(/\W/, '_').downcase}"
  end

end
