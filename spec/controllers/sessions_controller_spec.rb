require 'spec_helper'

describe SessionsController, "POST create" do

  before(:each) do
    community1 = FactoryGirl.create(:community, :consent => "test_consent0.1", :settings => {"locales" => ["en", "fi"]}, :real_name_required => true)
    person1 = FactoryGirl.create(:person, :username => "testpersonusername", :is_admin => 0, "locale" => "en", :encrypted_password => "64ae669314a3fb4b514fa5607ef28d3e1c1937a486e3f04f758270913de4faf5", :password_salt => "vGpGrfvaOhp3", :given_name => "Kassi", :family_name => "Testperson1", :phone_number => "0000-123456", :created_at => "2012-05-04 18:17:04")

    FactoryGirl.create(:community_membership, :person => person1,
                        :community => community1,
                        :admin => 1,
                        :consent => "test_consent0.1",
                        :last_page_load_date => DateTime.now,
                        :status => "accepted" )

    @request.host = "#{community1.ident}.lvh.me"
  end

  it "redirects back to original community's domain" do
    post :create, {:person  => {:login => "testpersonusername", :password => "testi"}}
    response.should redirect_to "http://#{@request.host}/?locale=en"
  end
end
