class Participation < ActiveRecord::Base
  
  belongs_to :conversation
  belongs_to :person

  validates_inclusion_of :is_read, :in => [true, false]
  
end
