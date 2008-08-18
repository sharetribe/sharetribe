class PersonComment < ActiveRecord::Base
  
  VALID_TASK_TYPES = ["listing", "item", "favor"]
  #there could also be polymorphic association for task_type
  belongs_to :author, :class_name => "Person", :foreign_key => "author_id"
  belongs_to :target_person, :class_name => "Person", :foreign_key => "target_person_id"
  
  #now the task_type and task_id can be nil, if later we'll have system where only person comments 
  validates_presence_of :author_id, :target_person_id, :grade
  validates_numericality_of :grade, :task_id, :only_integer => true
  
  validates_inclusion_of :grade, :in =>1..5
  validates_inclusion_of :task_type, :in => VALID_TASK_TYPES
end
