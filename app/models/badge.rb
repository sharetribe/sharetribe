class Badge < ActiveRecord::Base
  
  belongs_to :person
  
  UNIQUE_BADGES = [
    "rookie", "first_transaction"
  ]
  
end
