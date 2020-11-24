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
#  google_oauth2_id                   :string(255)
#  linkedin_id                        :string(255)
#
# Indexes
#
#  index_people_on_authentication_token               (authentication_token)
#  index_people_on_community_id                       (community_id)
#  index_people_on_community_id_and_google_oauth2_id  (community_id,google_oauth2_id)
#  index_people_on_community_id_and_linkedin_id       (community_id,linkedin_id)
#  index_people_on_email                              (email) UNIQUE
#  index_people_on_facebook_id                        (facebook_id)
#  index_people_on_facebook_id_and_community_id       (facebook_id,community_id) UNIQUE
#  index_people_on_google_oauth2_id                   (google_oauth2_id)
#  index_people_on_id                                 (id)
#  index_people_on_linkedin_id                        (linkedin_id)
#  index_people_on_reset_password_token               (reset_password_token) UNIQUE
#  index_people_on_username                           (username)
#  index_people_on_username_and_community_id          (username,community_id) UNIQUE
#  index_people_on_uuid                               (uuid) UNIQUE
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
      post :create, params: {:person => {:display_name => username, :password => "test", :email => "#{username}@example.com", :given_name => "", :family_name => ""}, :community => "test"}
      expect(Person.find_by(display_name: username, community_id: community.id)).not_to be_nil
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
                      selected_option_ids: [field4.options[0].id, field4.options[1].id] },
                    { type: "#{field5.class}Value", custom_field_id: field5.id,
                      :'date_value(1i)' => '2000', :'date_value(2i)' => '01', :'date_value(3i)' => '25' },
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
      expect(person.custom_field_value_for(field4).display_value).to eq field4.options.map(&:title).join(', ')
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

  describe "#update" do
    let(:community) { FactoryGirl.create(:community) }
    let(:field1) do
      FactoryGirl.create(:person_custom_text_field, community: community)
    end
    let(:field2) do
      FactoryGirl.create(:person_custom_dropdown_field, community: community)
    end
    let(:field3) do
      FactoryGirl.create(:custom_numeric_field, community: community)
    end
    let(:field4) do
      FactoryGirl.create(:custom_checkbox_field, community: community)
    end
    let(:field5) do
      FactoryGirl.create(:custom_date_field, community: community, required: false)
    end
    let(:person) do
      FactoryGirl.create(:person,
                         member_of: community,
                         custom_field_values_attributes: [
                           { type: "#{field1.class}Value", custom_field_id: field1.id, text_value: 'text1' },
                           { type: "#{field2.class}Value", custom_field_id: field2.id, selected_option_ids: [field2.options.first.id] },
                           { type: "#{field3.class}Value", custom_field_id: field3.id, numeric_value: '22' },
                           { type: "#{field4.class}Value", custom_field_id: field4.id,
                             selected_option_ids: [field4.options[0].id, field4.options[1].id] },
                           { type: "#{field5.class}Value", custom_field_id: field5.id,
                             :'date_value(1i)' => '2000', :'date_value(2i)' => '01', :'date_value(3i)' => '25' },
                         ])
    end

    before :each do
      sign_in_for_spec(person)
      community_host(community)
    end

    it 'works' do
      expect(person.custom_field_values.count).to eq 5
      expect(person.custom_field_value_for(field1).display_value).to eq 'text1'
      expect(person.custom_field_value_for(field2).display_value).to eq field2.options.first.title
      expect(person.custom_field_value_for(field3).display_value).to eq 22
      expect(person.custom_field_value_for(field4).display_value).to eq field4.options.map(&:title).join(', ')
      expect(person.custom_field_value_for(field5).display_value).to eq 'Jan 25, 2000'
      post :update, params: {
        id: person.username,
        person: {
                  given_name: "Kim", family_name: "Wise",
                  custom_field_values_attributes: [
                    { id: person.custom_field_value_for(field1), type: "#{field1.class}Value", custom_field_id: field1.id, text_value: 'would break faith' },
                    { id: person.custom_field_value_for(field2), type: "#{field2.class}Value", custom_field_id: field2.id, selected_option_ids: [field2.options.last.id] },
                    { id: person.custom_field_value_for(field3), type: "#{field3.class}Value", custom_field_id: field3.id, numeric_value: '33' },
                    { id: person.custom_field_value_for(field4), type: "#{field4.class}Value", custom_field_id: field4.id,
                      selected_option_ids: [field4.options[0].id] },
                    { id: person.custom_field_value_for(field5), type: "#{field5.class}Value", custom_field_id: field5.id,
                      :'date_value(1i)' => '2001', :'date_value(2i)' => '03', :'date_value(3i)' => '18' },
                  ]
      },
        community: "test"
      }
      person.reload
      expect(person.given_name).to eq "Kim"
      expect(person.family_name).to eq "Wise"
      expect(person.custom_field_values.count).to eq 5
      expect(person.custom_field_value_for(field1).display_value).to eq 'would break faith'
      expect(person.custom_field_value_for(field2).display_value).to eq field2.options.last.title
      expect(person.custom_field_value_for(field3).display_value).to eq 33
      expect(person.custom_field_value_for(field4).display_value).to eq field4.options.first.title
      expect(person.custom_field_value_for(field5).display_value).to eq 'Mar 18, 2001'
    end

    it 'should update custom fields checkbox value when all options are unselected' do
      expect(person.custom_field_values.count).to eq 5
      expect(person.custom_field_value_for(field4).display_value).to eq field4.options.map(&:title).join(', ')
      post :update, params: {
        id: person.username,
        person: {
                  given_name: "Kim", family_name: "Wise",
                  custom_field_values_attributes: [
                    { id: person.custom_field_value_for(field1), type: "#{field1.class}Value", custom_field_id: field1.id, text_value: 'would break faith' },
                    { id: person.custom_field_value_for(field2), type: "#{field2.class}Value", custom_field_id: field2.id, selected_option_ids: [field2.options.last.id] },
                    { id: person.custom_field_value_for(field3), type: "#{field3.class}Value", custom_field_id: field3.id, numeric_value: '33' },
                    { id: person.custom_field_value_for(field4), type: "#{field4.class}Value", custom_field_id: field4.id,
                      selected_option_ids: [""] },
                    { id: person.custom_field_value_for(field5), type: "#{field5.class}Value", custom_field_id: field5.id,
                      :'date_value(1i)' => '', :'date_value(2i)' => '', :'date_value(3i)' => '' },
                  ]
      },
        community: "test"
      }
      person.reload
      expect(person.custom_field_values.count).to eq 5
      expect(person.custom_field_value_for(field4).display_value).to eq ''
    end

    it 'should update custom fields dropdown value when all options are unselected' do
      expect(person.custom_field_values.count).to eq 5
      expect(person.custom_field_value_for(field2).display_value).to eq field2.options.first.title
      post :update, params: {
        id: person.username,
        person: {
                  given_name: "Kim", family_name: "Wise",
                  custom_field_values_attributes: [
                    { id: person.custom_field_value_for(field1), type: "#{field1.class}Value", custom_field_id: field1.id, text_value: 'would break faith' },
                    { id: person.custom_field_value_for(field2), type: "#{field2.class}Value", custom_field_id: field2.id, selected_option_ids: [""] },
                    { id: person.custom_field_value_for(field3), type: "#{field3.class}Value", custom_field_id: field3.id, numeric_value: '33' },
                    { id: person.custom_field_value_for(field4), type: "#{field4.class}Value", custom_field_id: field4.id,
                      selected_option_ids: [""] },
                    { id: person.custom_field_value_for(field5), type: "#{field5.class}Value", custom_field_id: field5.id,
                      :'date_value(1i)' => '2001', :'date_value(2i)' => '03', :'date_value(3i)' => '18' },
                  ]
      },
        community: "test"
      }
      person.reload
      expect(person.given_name).to eq "Kim"
      expect(person.family_name).to eq "Wise"
      expect(person.custom_field_values.count).to eq 5
      expect(person.custom_field_value_for(field2).display_value).to eq ''
    end
  end

  describe "#show" do
    render_views

    let(:plan) do
      {
        expired: false,
        features: {
          whitelabel: true,
          admin_email: true,
          footer: false
        },
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      }
    end

    before(:each) do
      @request.env[:current_plan] = plan
    end

    let(:community) do
      community = FactoryGirl.create(:community)
      FactoryGirl.create(:custom_text_field, community: community,
                                             public: true, entity_type: :for_person)
      community
    end
    let(:person1) do
      person = FactoryGirl.create(:person, member_of: community, community_id: community.id)
      FactoryGirl.create(:testimonial, tx: FactoryGirl.create(:transaction, community: community),
                                       receiver: person, grade: 0)
      FactoryGirl.create(:testimonial, tx: FactoryGirl.create(:transaction, community: community),
                                       receiver: person, grade: 1)
      FactoryGirl.create(:testimonial, tx: FactoryGirl.create(:transaction, community: community),
                                       receiver: person, grade: 1)
      followed_person = FactoryGirl.create(:person, member_of: community, community_id: community.id)
      followed_person.followers << person
      person
    end
    let(:person_banned) do
      person = FactoryGirl.create(:person, community_id: community.id)
      person.create_community_membership(community: community, status: CommunityMembership::BANNED)
      person
    end
    let(:person_deleted) { FactoryGirl.create(:person, member_of: community, community_id: community.id, deleted: true) }

    it 'works' do
      community_host(community)
      get :show, params: {username: person1.username}
      service = assigns(:service)
      expect(service.person).to eq person1
      expect(service.received_testimonials?).to eq true
      expect(service.received_testimonials.count).to eq 3
      expect(service.received_positive_testimonials.count).to eq 2
      expect(service.feedback_positive_percentage).to eq 67
      expect(service.community_person_custom_fields.count).to eq 1
      expect(service.followed_people.count).to eq 1
    end

    it 'does not show banned person' do
      community_host(community)
      get :show, params: {username: person_banned.username}
      expect(response).to redirect_to('/')
    end

    it 'does not show deleted person' do
      community_host(community)
      get :show, params: {username: person_deleted.username}
      expect(response).to redirect_to('/')
    end

    it "shows specific meta title and description" do
      community_host(community)
      community.community_customizations.first.update(profile_meta_title: "Profile for {{user_display_name}}", profile_meta_description: "Want to know more about {{user_display_name}}")
      get :show, params: {username: person1.username}
      user_name = person1.name_or_username(community)
      expect(response.body).to match("<title>Profile for #{user_name}</title>")
      expect(response.body).to match("<meta content='Want to know more about #{user_name}' name='description'>")
    end
  end

  describe "#update" do
    let(:community) { FactoryGirl.create(:community) }
    let(:field1) do
      FactoryGirl.create(:custom_numeric_field, community: community, entity_type: :for_person)
    end
    let(:admin) {
      FactoryGirl.create(:person, member_of: community,
                                  member_is_admin: true,
                                  community_id: community.id)
    }
    let(:person) do
      person = FactoryGirl.create(:person, member_of: community,
                                           community_id: community.id,
                                           username: 'louisemorris',
                                           given_name: 'Louise',
                                           family_name: 'Morris',
                                           display_name: 'Morris Ltd'
                                          )
      person.custom_field_values << FactoryGirl.create(:custom_numeric_field_value,
                                                       question: field1,
                                                       listing: nil,
                                                       numeric_value: 77)
      person
    end

    it 'person updates itself' do
      sign_in_for_spec(person)
      community_host(community)
      expect(person.custom_field_value_for(field1).display_value).to eq 77
      value_id = person.custom_field_value_for(field1).id
      patch :update, params: {
        id: 'louisemorris',
        person: { password: "12345678", password2: "12345678",
                  given_name: "Norma", family_name: "Scott", display_name: 'Scott Ltd',
                  custom_field_values_attributes: [
                    {id: value_id, type: "#{field1.class}Value", custom_field_id: field1.id, numeric_value: '22' },
                  ]
      },
        community: "test"
      }
      person.reload
      expect(person.valid_password?('12345678')).to eq true
      expect(person.given_name).to eq "Norma"
      expect(person.family_name).to eq "Scott"
      expect(person.display_name).to eq "Scott Ltd"
      expect(person.custom_field_value_for(field1).display_value).to eq 22
    end

    it 'person updated by admin' do
      sign_in_for_spec(admin)
      community_host(community)
      expect(person.custom_field_value_for(field1).display_value).to eq 77
      value_id = person.custom_field_value_for(field1).id
      patch :update, params: {
        id: 'louisemorris',
        person: {
                  given_name: "Norma", family_name: "Scott", display_name: 'Scott Ltd',
                  custom_field_values_attributes: [
                    {id: value_id, type: "#{field1.class}Value", custom_field_id: field1.id, numeric_value: '22' },
                  ]
      },
        community: "test"
      }
      person.reload
      expect(person.given_name).to eq "Norma"
      expect(person.family_name).to eq "Scott"
      expect(person.display_name).to eq "Scott Ltd"
      expect(person.custom_field_value_for(field1).display_value).to eq 22
    end

    it 'person updates username' do
      sign_in_for_spec(person)
      community_host(community)
      expect(person.username).to eq 'louisemorris'
      expect(
        patch(:update, params: {
          id: 'louisemorris',
          referer_form: 'settings',
          person: { username: 'scott' },
          community: "test"
        })
      ).to redirect_to('/en/scott/settings')
      person.reload
      expect(person.username).to eq 'scott'
    end

    it 'person cannot update username to invalid' do
      sign_in_for_spec(person)
      community_host(community)
      request.env['HTTP_REFERER'] = '/en/louisemorris/settings'
      expect(person.username).to eq 'louisemorris'
      expect(
        patch(:update, params: {
          id: 'louisemorris',
          referer_form: 'settings',
          person: { username: 'about' },
          community: "test"
        })
      ).to redirect_to('/en/louisemorris/settings')
      person.reload
      expect(person.username).to eq 'louisemorris'
    end
  end

  def community_host(community)
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
  end
end
