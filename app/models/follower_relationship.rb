# == Schema Information
#
# Table name: follower_relationships
#
#  id          :integer          not null, primary key
#  person_id   :string(255)      not null
#  follower_id :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_follower_relationships_on_follower_id                (follower_id)
#  index_follower_relationships_on_person_id                  (person_id)
#  index_follower_relationships_on_person_id_and_follower_id  (person_id,follower_id) UNIQUE
#

class FollowerRelationship < ApplicationRecord

  belongs_to :person
  belongs_to :follower, :class_name => "Person"

  validates :person_id,
            :presence => true
  validates :follower_id,
            :presence => true,
            :uniqueness => { :scope => :person_id },
            :exclusion => { :in => lambda { |x| [ x.person_id ] } }

end
