class PersonComment < ActiveRecord::Base
  
  VALID_TASK_TYPES = ["listing", "item", "favor"]

  belongs_to :author, :class_name => "Person", :foreign_key => "author_id"
  belongs_to :target_person, :class_name => "Person", :foreign_key => "target_person_id"
  
  validates_presence_of :author_id, :target_person_id
  validates_numericality_of :grade, :task_id, :allow_nil => true, :only_integer => true
  
  validates_inclusion_of :grade, :in => 1..5
  validates_inclusion_of :task_type, :in => VALID_TASK_TYPES
  
end
