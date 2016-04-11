# == Schema Information
#
# Table name: emails
#
#  id                   :integer          not null, primary key
#  person_id            :string(255)
#  community_id         :integer
#  address              :string(255)
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  confirmation_token   :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  send_notifications   :boolean
#
# Indexes
#
#  index_emails_on_address                   (address)
#  index_emails_on_address_and_community_id  (address,community_id) UNIQUE
#  index_emails_on_person_id                 (person_id)
#

require 'spec_helper'

describe Email, type: :model do
  describe "before_save" do
    it "downcases address" do
      e = Email.create(:address => "TeST@eXample.COM", :person => FactoryGirl.create(:person))
      expect(Email.find(e.id).address).to eq("test@example.com")
    end
  end
end
