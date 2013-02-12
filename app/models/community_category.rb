class CommunityCategory < ActiveRecord::Base
  belongs_to :community
  belongs_to :category
  belongs_to :share_type
  
  validates_presence_of :category
end
