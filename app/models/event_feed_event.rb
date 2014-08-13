# == Schema Information
#
# Table name: event_feed_events
#
#  id             :integer          not null, primary key
#  person1_id     :string(255)
#  person2_id     :string(255)
#  community_id   :string(255)
#  eventable_id   :integer
#  eventable_type :string(255)
#  category       :string(255)
#  members_only   :boolean          default(FALSE)
#  created_at     :datetime
#  updated_at     :datetime
#

class EventFeedEvent < ActiveRecord::Base

  # In case of offer/request, person1 is always offerer and person2 requester
  belongs_to :person1, :class_name => "Person", :foreign_key => "person1_id"
  belongs_to :person2, :class_name => "Person", :foreign_key => "person2_id"
  belongs_to :community
  belongs_to :eventable, :polymorphic => true

  validates_presence_of :community_id, :category

  scope :non_members_only, :conditions => { :members_only => false }

end
