class KassiEvent < ActiveRecord::Base
  
  belongs_to :eventable, :polymorphic => true
  
  has_and_belongs_to_many :people
  
  has_many :person_comments
  
  belongs_to :realizer, :class_name => "Person"
  
  belongs_to :receiver, :class_name => "Person", :foreign_key => "receiver_id"
  
  attr_accessor :comment
  
end
