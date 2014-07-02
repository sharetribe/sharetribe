class FollowerRelationship < ActiveRecord::Base
  
  attr_accessible :follower_id, :person_id
  
  belongs_to :person
  belongs_to :follower, :class_name => "Person"
  
  validates :person_id, 
            :presence => true
  validates :follower_id, 
            :presence => true, 
            :uniqueness => { :scope => :person_id },
            :exclusion => { :in => lambda { |x| [ x.person_id ] } }
  
end
