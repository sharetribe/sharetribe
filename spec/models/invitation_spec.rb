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
#  message      :text(65535)
#  email        :string(255)
#
# Indexes
#
#  index_invitations_on_code        (code)
#  index_invitations_on_inviter_id  (inviter_id)
#

require 'spec_helper'

describe Invitation, type: :model do

  describe "#create" do
    it "generates a code automatically" do
      i = Invitation.create
      expect(i.code).not_to be_nil
      expect(i.code.length).to eq(6)
    end

  end

  describe "#use" do
    it "reduces usages left by one" do
      i = FactoryGirl.create(:invitation)
      expect(i.usages_left).to eq(1)
      i.save!
      expect(Invitation.find(i.id).usages_left).to eq(1)
      expect(i).to be_usable
      #i.use_once!
      i.update_attribute(:usages_left, i.usages_left - 1)
      expect(i.usages_left).to eq(0)
      i.save!
      expect(Invitation.find(i.id).usages_left).to eq(0)
      expect(i).not_to be_usable
      i.usages_left = 3
      i.use_once!
      expect(i.usages_left).to eq(2)
      expect(i).to be_usable

    end
  end
end
