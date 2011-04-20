class Location < ActiveRecord::Base
  belongs_to :person
  belongs_to :listing
end
