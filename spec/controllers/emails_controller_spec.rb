# == Schema Information
#
# Table name: emails
#
#  id                   :integer          not null, primary key
#  person_id            :string(255)
#  community_id         :integer          not null
#  address              :string(255)      not null
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
#  index_emails_on_community_id              (community_id)
#  index_emails_on_confirmation_token        (confirmation_token)
#  index_emails_on_person_id                 (person_id)
#

require 'spec_helper'

describe EmailsController, type: :controller do
  describe "#destroy" do
    before(:each) do
      @community = FactoryGirl.create(:community)
      @request.host = "#{@community.ident}.lvh.me"
      @request.env[:current_marketplace] = @community
    end

    it "should destroy email" do
      person = FactoryGirl.create(:person)
      person.emails = [
        FactoryGirl.create(:email, :address => "one@examplecompany.co", :send_notifications => true),
        FactoryGirl.create(:email, :address => "two@examplecompany.co", :send_notifications => true)
      ]
      person.save!

      @community.members << person
      sign_in_for_spec(person)

      expect(Email.where(person_id: person.id).count).to eq(2)

      delete :destroy, params: {:person_id => person.id, :id => person.emails.first.id}

      expect(Email.where(person_id: person.id).count).to eq(1)
      expect(response.status).to eq(302)
    end

    it "should not destroy email if that's not allowed" do
      # Don't test all edge cases here. They are covered in specs
      person = FactoryGirl.create(:person)
      person.emails = [
        FactoryGirl.create(:email, :address => "one@examplecompany.co", :send_notifications => true),
        FactoryGirl.create(:email, :address => "two@examplecompany.co", :send_notifications => false)
      ]
      person.save!

      @community.members << person
      sign_in_for_spec(person)

      expect(Email.where(person_id: person.id).count).to eq(2)

      delete :destroy, params: {:person_id => person.id, :id => person.emails.first.id}

      expect(Email.where(person_id: person.id).count).to eq(2)
      expect(response.status).to eq(302)
    end
  end
end
