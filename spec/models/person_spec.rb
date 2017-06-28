# == Schema Information
#
# Table name: people
#
#  id                                 :string(22)       not null, primary key
#  uuid                               :binary(16)       not null
#  community_id                       :integer          not null
#  created_at                         :datetime
#  updated_at                         :datetime
#  is_admin                           :integer          default(0)
#  locale                             :string(255)      default("fi")
#  preferences                        :text(65535)
#  active_days_count                  :integer          default(0)
#  last_page_load_date                :datetime
#  test_group_number                  :integer          default(1)
#  username                           :string(255)      not null
#  email                              :string(255)
#  encrypted_password                 :string(255)      default(""), not null
#  legacy_encrypted_password          :string(255)
#  reset_password_token               :string(255)
#  reset_password_sent_at             :datetime
#  remember_created_at                :datetime
#  sign_in_count                      :integer          default(0)
#  current_sign_in_at                 :datetime
#  last_sign_in_at                    :datetime
#  current_sign_in_ip                 :string(255)
#  last_sign_in_ip                    :string(255)
#  password_salt                      :string(255)
#  given_name                         :string(255)
#  family_name                        :string(255)
#  display_name                       :string(255)
#  phone_number                       :string(255)
#  description                        :text(65535)
#  image_file_name                    :string(255)
#  image_content_type                 :string(255)
#  image_file_size                    :integer
#  image_updated_at                   :datetime
#  image_processing                   :boolean
#  facebook_id                        :string(255)
#  authentication_token               :string(255)
#  community_updates_last_sent_at     :datetime
#  min_days_between_community_updates :integer          default(1)
#  deleted                            :boolean          default(FALSE)
#  cloned_from                        :string(22)
#
# Indexes
#
#  index_people_on_authentication_token          (authentication_token)
#  index_people_on_community_id                  (community_id)
#  index_people_on_email                         (email) UNIQUE
#  index_people_on_facebook_id                   (facebook_id)
#  index_people_on_facebook_id_and_community_id  (facebook_id,community_id) UNIQUE
#  index_people_on_id                            (id)
#  index_people_on_reset_password_token          (reset_password_token) UNIQUE
#  index_people_on_username                      (username)
#  index_people_on_username_and_community_id     (username,community_id) UNIQUE
#  index_people_on_uuid                          (uuid) UNIQUE
#

require 'spec_helper'

describe Person, type: :model do

   before(:all) do
      #These will be created only once for the whole example group
      @test_person = FactoryGirl.create(:person)
    end

    it "should be valid" do
      expect(@test_person.class).to eq(Person)
      expect(@test_person).not_to be_nil
      expect(@test_person).to be_valid
    end

    it "should have an id other than 0" do
      expect(@test_person.id).not_to eq(0)
      # "Test_person.id is 0, possible reason is INT type for id in test DB."
    end

    describe "#create" do
      it "should create a person in Sharetribe DB" do
        username = generate_random_username
        p = Person.create!({:username => username,
          community_id: 1,
          :password => "testi",
          :email => "#{username}@example.com",
          "given_name" => "Tero",
          "family_name" => "Turari"})
        expect(Person.find(p.id)).not_to be_nil
        expect(p.username).to eq(username)
      end

      it "should not store anything to Sharetribe DB if creation failed for invalid data" do
        username = generate_random_username
        expect {
          p = nil
          expect {
            p = Person.create!({:username => username,
              community_id: 1,
              :password => "testi",
              :emails => [Email.new(:address => "invalid-email")],
              "given_name" => "Tero",
              "family_name" => "Turari"})
          }.to raise_error(ActiveRecord::RecordInvalid)
          expect(p).to be_nil
        }.not_to change{Person.count}
      end
    end

    describe "#update_attributes" do
      it "should update the attributes" do
        @test_person.update_attributes({'given_name' => "Totti",
          'family_name' => "Tester",
          'phone_number' => "050-55555555"})
        expect(@test_person.family_name).to eq("Tester")
        expect(@test_person.phone_number).to eq("050-55555555")
      end
    end

    describe "#create_listing" do
      it "creates a new listing with the submitted attributes" do
        listing = FactoryGirl.create(:listing,
          :title => "Test",
          :author => @test_person,
          :listing_shape_id => 123
        )
        expect(listing.title).to eq("Test")
        expect(@test_person.listings.last).to eq(listing)
      end
    end

    describe "name getters" do
      before(:each) do
        @test_person.update_attributes({'given_name' => "Ripa", 'family_name' => "Riuska"})
      end

      it "returns the name of the user" do
        expect(@test_person.name('first_name_with_initial')).not_to be_blank
        expect(@test_person.name('first_name_with_initial')).to eq("Ripa R")
      end

      it "returns the given or the last name of the user" do
        expect(@test_person.given_name).to eq("Ripa")
        expect(@test_person.family_name).to eq("Riuska")
      end

      it "returns the name in desired format" do
        expect(@test_person.name("first_name_with_initial")).to eq("Ripa R")
        expect(@test_person.name("first_name_only")).to eq("Ripa")
        expect(@test_person.name("full_name")).to eq("Ripa Riuska")
      end


      describe "#given_name" do

        it "should return the given name" do
          expect(@test_person.given_name).to eq("Ripa")
        end

        it "should return blank if given name is blank" do
          @test_person.update_attributes({'given_name' => "", 'family_name' => ""})
          expect(@test_person.given_name).to eq("")
        end

      end

      describe "#given_name_or_username" do

        it "should return the given name if it exists" do
          expect(@test_person.given_name_or_username).to eq("Ripa")
        end

        it "should return username if given name is blank" do
          @test_person.update_attributes({'given_name' => "", 'family_name' => ""})
          expect(@test_person.given_name_or_username).to eq(@test_person.username)
        end

      end

      describe "devise valid_password?" do
        it "Test that the hashing works. (makes more sense to test this if ASI digest is used)" do
          expect(FactoryGirl.build(:person).valid_password?('testi')).to be_truthy
          expect(FactoryGirl.build(:person).valid_password?('something_else')).not_to be_truthy
        end
      end

    end

    describe "#delete" do
      it "should delete also related conversations and testimonials" do
        conv = FactoryGirl.create(:conversation)
        conv.participants << @test_person
        conv_id = conv.id
        expect(Conversation.find_by_id(conv_id)).not_to be_nil
        expect(@test_person.conversations).to include(conv)

        tes = FactoryGirl.create(:testimonial, :author => @test_person)
        tes_id = tes.id
        expect(Testimonial.find_by_id(tes_id)).not_to be_nil
        expect(@test_person.authored_testimonials).to include(tes)

        @test_person.destroy

        # check that related stuff was removed too
        expect(Conversation.find_by_id(conv_id)).to be_nil
        expect(Testimonial.find_by_id(tes_id)).to be_nil

      end
    end

    describe "#latest_pending_email_address" do

      before (:each) do
        @p = FactoryGirl.create(:person)
      end

      it "should return nil if none pending" do
        expect(@p.latest_pending_email_address()).to be_nil
      end

      it "should return main email if that's pending" do
        @p.emails.each { |email| email.update_attribute(:confirmed_at, nil) }
        expect(@p.latest_pending_email_address()).to match(/kassi_tester\d+@example.com/)
      end

      it "should pick the right email to return" do
        c = FactoryGirl.create(:community, :allowed_emails => "@example.com, @ex.ample, @something.else")
        e = FactoryGirl.create(:email, :address => "jack@aalto.fi", :confirmed_at => nil, :person => @p)
        e2 = FactoryGirl.create(:email, :address => "jack@example.com", :confirmed_at => nil, :person => @p)
        # e3 = FactoryGirl.create(:email, :address => "jack@helsinki.fi", :confirmed_at => nil, :person => @p)

        expect(@p.latest_pending_email_address(c)).to eq("jack@example.com")
      end
    end

  describe "inherits_settings_from" do
    let(:person) { FactoryGirl.build(:person) }
    let(:community) { FactoryGirl.build(:community, :default_min_days_between_community_updates => 30) }

    it "inherits_settings_from" do
      person.inherit_settings_from(community)

      expect(person.min_days_between_community_updates).to eql(30)
    end

  end

end
