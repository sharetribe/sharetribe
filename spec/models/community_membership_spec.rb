# == Schema Information
#
# Table name: community_memberships
#
#  id                  :integer          not null, primary key
#  person_id           :string(255)      not null
#  community_id        :integer          not null
#  admin               :boolean          default(FALSE)
#  created_at          :datetime
#  updated_at          :datetime
#  consent             :string(255)
#  invitation_id       :integer
#  last_page_load_date :datetime
#  status              :string(255)      default("accepted"), not null
#  can_post_listings   :boolean          default(FALSE)
#
# Indexes
#
#  index_community_memberships_on_community_id  (community_id)
#  index_community_memberships_on_person_id     (person_id) UNIQUE
#

require 'spec_helper'

describe CommunityMembership, type: :model do

  before(:each) do
    @community_membership = FactoryGirl.build(:community_membership)
  end

  it "is valid with valid attributes" do
    expect(@community_membership).to be_valid
  end

end
