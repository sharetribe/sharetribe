# == Schema Information
#
# Table name: emails
#
#  id                   :integer          not null, primary key
#  person_id            :string(255)
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
#  index_emails_on_address    (address) UNIQUE
#  index_emails_on_person_id  (person_id)
#

require 'spec_helper'

describe Email do
  describe "before_save" do
    it "downcases address" do
      e = Email.create(:address => "TeST@eXample.COM", :person => FactoryGirl.create(:person))
      Email.find(e.id).address.should == "test@example.com"
    end
  end
end
