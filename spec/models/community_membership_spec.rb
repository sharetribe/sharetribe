# == Schema Information
#
# Table name: community_memberships
#
#  id                  :integer          not null, primary key
#  person_id           :string(255)
#  community_id        :integer
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
#  memberships                                  (person_id,community_id)
#

require 'spec_helper'

describe CommunityMembership do

  before(:each) do
    @community_membership = FactoryGirl.build(:community_membership)
  end

  it "is valid with valid attributes" do
    @community_membership.should be_valid
  end

end
