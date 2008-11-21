class KassiEvent < ActiveRecord::Base
  
  belongs_to :eventable, :polymorphic => true
  
  has_and_belongs_to_many :people
  
end
