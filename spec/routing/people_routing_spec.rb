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

require "spec_helper"

describe "routing for people", type: :routing do

  before(:each) do
    @community = FactoryGirl.create(:community)
    @protocol_and_host = "http://#{@community.ident}.test.host"

    # Person with username with no substrings that match a valid locale
    @person = FactoryGirl.create(:person, username: "u1234")

    # Person with username with a locale present as substring
    @person_with_locale_substring = FactoryGirl.create(:person, username: "fooen")
  end

  it "routes /:username to people controller" do
    expect(get "/#{@person.username}").to(
      route_to(
        {
          :controller => "people",
          :action => "show",
          :username => @person.username
        }
      )
    )
  end

  it "routes /:username to people controller when username has locale as substring" do
    expect(get "/#{@person_with_locale_substring.username}").to(
      route_to(
        {
          :controller => "people",
          :action => "show",
          :username => @person_with_locale_substring.username
        }
      )
    )
  end

  it "routes /:username/settings to settings controller" do
    expect(get "/#{@person.username}/settings").to(
      route_to(
        {
          :controller => "settings",
          :action => "show",
          :person_id => @person.username
        }
      )
    )
  end

  it "routes /en to home page" do
    expect(get "#{@protocol_and_host}/en").to(
      route_to({
                 :controller => "homepage",
                 :action => "index",
                 :locale => "en"
               }))
  end

  it "routes /pt-BR to home page" do
    expect(get "/pt-BR").to(
      route_to({
                 :controller => "homepage",
                 :action => "index",
                 :locale => "pt-BR"
               }))
  end

  it "routes / to home page" do
    expect(get "/").to(
      route_to({
                 :controller => "homepage",
                 :action => "index"
               }))
  end

  it "routes /login to login" do
    expect(get "/login").to(
      route_to({
                 :controller => "sessions",
                 :action => "new"
               }))
  end

  it "routes /logout to logout" do
    expect(get "/logout").to(
      route_to({
                 :controller => "sessions",
                 :action => "destroy"
               }))
  end

  it "routes /en/login to login" do
    expect(get "/en/login").to(
      route_to({
                 :controller => "sessions",
                 :action => "new",
                 :locale => "en"
               }))
  end
end
