# == Schema Information
#
# Table name: invitations
#
#  id           :integer          not null, primary key
#  code         :string(255)
#  community_id :integer
#  usages_left  :integer
#  valid_until  :datetime
#  information  :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  inviter_id   :string(255)
#  message      :text
#  email        :string(255)
#
# Indexes
#
#  index_invitations_on_code        (code)
#  index_invitations_on_inviter_id  (inviter_id)
#

require 'spec_helper'

describe Invitation do

  describe "#create" do
    it "generates a code automatically" do
      i = Invitation.create
      i.code.should_not be_nil
      i.code.length.should == 6
    end

  end

  describe "#use" do
    it "reduces usages left by one" do
      i = FactoryGirl.create(:invitation)
      i.usages_left.should == 1
      i.save!
      Invitation.find(i.id).usages_left.should == 1
      i.should be_usable
      #i.use_once!
      i.update_attribute(:usages_left, i.usages_left - 1)
      i.usages_left.should == 0
      i.save!
      Invitation.find(i.id).usages_left.should == 0
      i.should_not be_usable
      i.usages_left = 3
      i.use_once!
      i.usages_left.should == 2
      i.should be_usable

    end
  end
end
