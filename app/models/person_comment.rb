class PersonComment < ActiveRecord::Base
  
  belongs_to :author, :class_name => "Person", :foreign_key => "author_id"
  belongs_to :target_person, :class_name => "Person", :foreign_key => "target_person_id"
  belongs_to :kassi_event
  
  validates_presence_of :author_id, :target_person_id
  validates_numericality_of :grade, :allow_nil => true
  validates_inclusion_of :grade, :in => 0..1
  
  # Returns the grade normalized to scale 1-3
  def grade_value
    (grade*2).to_i + 1 
  end
  
  # Returns a string label for the grade
  def grade_label
    case grade
    when 0
      return "less_than_expected"
    when 0.5
      return "as_expected"
    when 1
      return "exceeded_expectations"
    end         
  end
  
end
