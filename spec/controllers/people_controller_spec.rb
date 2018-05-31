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

describe PeopleController, type: :controller do

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:person]
  end

  describe "#check_email_availability" do
    before(:each) do
      community = FactoryGirl.create(:community)
      @request.host = "#{community.ident}.lvh.me"
      @request.env[:current_marketplace] = community
    end

    it "should return available if email not in use" do
      get :check_email_availability, params: {:person => {:email => "totally_random_email_not_in_use@example.com"}, :format => :json}
      expect(response.body).to eq("true")
    end
  end

  describe "#check_email_availability" do
    before(:each) do
      @community = FactoryGirl.create(:community)
      @request.host = "#{@community.ident}.lvh.me"
      @request.env[:current_marketplace] = @community
    end

    it "should return unavailable if email is in use" do
      person = FactoryGirl.create(:person, community_id: @community.id, :emails => [
                                    FactoryGirl.create(:email, community_id: @community.id, :address => "test@example.com")])
      FactoryGirl.create(:community_membership,
                         community: @community,
                         person: person,
                         admin: 0,
                         consent: "test_consent0.1",
                         last_page_load_date: DateTime.now,
                         status: "accepted")

      get :check_email_availability, params: {:person => {:email_attributes => {:address => "test@example.com"} }, :format => :json}
      expect(response.body).to eq("false")

      Email.create(:person_id => person.id, community_id: @community.id, :address => "test2@example.com")
      get :check_email_availability, params: {:person => {:email_attributes => {:address => "test2@example.com"} }, :format => :json}
      expect(response.body).to eq("false")
    end

    it "should return NOT available for user's own adress" do
      person = FactoryGirl.create(:person, community_id: @community.id)
      FactoryGirl.create(:community_membership,
                         community: @community,
                         person: person,
                         admin: 0,
                         consent: "test_consent0.1",
                         last_page_load_date: DateTime.now,
                         status: "accepted")
      sign_in person

      Email.create(:person_id => person.id, community_id: @community.id, :address => "test2@example.com")
      get :check_email_availability, params: {:person => {:email_attributes => {:address => "test2@example.com"} }, :format => :json}
      expect(response.body).to eq("false")
    end

  end

  describe "#create" do
    let(:ordinary_community) { FactoryGirl.create(:community) }
    let(:no_allowed_emails_community) { FactoryGirl.create(:community, allowed_emails: "@examplecompany.co") }
    let(:field1) do
      FactoryGirl.create(:person_custom_text_field, community: ordinary_community)
    end
    let(:field2) do
      FactoryGirl.create(:person_custom_dropdown_field, community: ordinary_community)
    end
    let(:field3) do
      FactoryGirl.create(:custom_numeric_field, community: ordinary_community)
    end
    let(:field4) do
      FactoryGirl.create(:custom_checkbox_field, community: ordinary_community)
    end
    let(:field5) do
      FactoryGirl.create(:custom_date_field, community: ordinary_community)
    end

    it "creates a person" do
      community = ordinary_community
      community_host(community)
      person_count = Person.count
      username = generate_random_username
      post :create, params: {:person => {:username => username, :password => "test", :email => "#{username}@example.com", :given_name => "", :family_name => ""}, :community => "test"}
      expect(Person.find_by(username: username, community_id: community.id)).not_to be_nil
      expect(Person.count).to eq(person_count + 1)
    end

    it "doesn't create a person for community if email is not allowed" do

      username = generate_random_username
      community = no_allowed_emails_community
      community_host(no_allowed_emails_community)

      post :create, params: {:person => {:username => username, :password => "test", :email => "#{username}@example.com", :given_name => "", :family_name => ""}}

      expect(Person.find_by(username: username, community_id: community.id)).to be_nil
      expect(flash[:error].to_s).to include("This email is not allowed")
    end

    it "creates a person with custom fields" do
      community = ordinary_community
      community_host(community)
      person_count = Person.count
      username = generate_random_username
      post :create, params: {
        person: { username: username, password: "test", email: "#{username}@example.com",
                  given_name: "", family_name: "",
                  custom_field_values_attributes: [
                    { type: "#{field1.class}Value", custom_field_id: field1.id, text_value: 'text1' },
                    { type: "#{field2.class}Value", custom_field_id: field2.id, selected_option_ids: [field2.options.first.id] },
                    { type: "#{field3.class}Value", custom_field_id: field3.id, numeric_value: '22' },
                    { type: "#{field4.class}Value", custom_field_id: field4.id,
                      selected_option_ids: [field2.options[0].id, field2.options[1].id] },
                    { type: "#{field5.class}Value", custom_field_id: field5.id,
                      :'date_value(1i)' => 2000, :'date_value(2i)' => 0o1, :'date_value(3i)' => 25 },
                  ]
      },
        community: "test"
      }
      expect(Person.count).to eq(person_count + 1)
      person = assigns(:person)
      expect(person).not_to be_nil
      expect(person.custom_field_values.count).to eq 5
      expect(person.custom_field_value_for(field1).display_value).to eq 'text1'
      expect(person.custom_field_value_for(field2).display_value).to eq field2.options.first.title
      expect(person.custom_field_value_for(field3).display_value).to eq 22
      expect(person.custom_field_value_for(field4).display_value).to eq field2.options.map(&:title).join(', ')
      expect(person.custom_field_value_for(field5).display_value).to eq 'Jan 25, 2000'
    end

    it "not creates a person with invalid custom fields" do
      community = ordinary_community
      community_host(community)
      username = generate_random_username
      post :create, params: {
        person: { username: username, password: "test", email: "#{username}@example.com",
                  given_name: "", family_name: "",
                  custom_field_values_attributes: [
                    { type: "#{field1.class}Value", custom_field_id: field1.id, text_value: '' },
                  ]
      },
        community: "test"
      }
      person = assigns(:person)
      expect(person.persisted?).to eq false
    end
  end

  describe "#destroy" do
    before(:each) do
      @community = FactoryGirl.create(:community)
      @request.host = "#{@community.ident}.lvh.me"
      @request.env[:current_marketplace] = @community
      @location = FactoryGirl.create(:location)
      @person = FactoryGirl.create(:person,
                                   community_id: @community.id,
                                   location: @location,
                                   display_name: "A User",
                                   description: "My bio.")
      @community.members << @person
      @id = @person.id
      @username = @person.username
      expect(Person.find_by(username: @username, community_id: @community.id)).not_to be_nil
    end

    it "deletes the person" do
      sign_in_for_spec(@person)

      delete :destroy, params: {:id => @username}
      expect(response.status).to eq(302)

      person = Person.find(@id)
      expect(person.deleted?).to eql(true)
      expect(person.username).to match(/deleted_\w+/)
      expect(person.location).to be_nil
      expect(person.phone_number).to be_nil
      expect(person.given_name).to be_nil
      expect(person.family_name).to be_nil
      expect(person.display_name).to be_nil
      expect(person.description).to be_nil
    end

    it "doesn't delete if not logged in as target person" do
      b = FactoryGirl.create(:person)
      @community.members << b
      sign_in_for_spec(b)

      delete :destroy, params: {:id => @username}
      expect(response.status).to eq(302)

      expect(Person.find_by(username: @username, community_id: @community.id)).not_to be_nil
    end

  end

  def community_host(community)
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
  end
end
