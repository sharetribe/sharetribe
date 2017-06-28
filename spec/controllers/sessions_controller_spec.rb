require 'spec_helper'

describe SessionsController, "POST create", type: :controller do

  before(:each) do
    community1 = FactoryGirl.create(:community,
                                    consent: "test_consent0.1",
                                    settings: {"locales" => ["en", "fi"]},
                                    real_name_required: true)

    person1 = FactoryGirl.create(:person,
                                 username: "testpersonusername",
                                 is_admin: 0, "locale" => "en",
                                 encrypted_password: "$2a$10$WQHcobA3hrTdSDh1jfiMquuSZpM3rXlcMU71bhE1lejzBa3zN7yY2",
                                 given_name: "Kassi",
                                 family_name: "Testperson1",
                                 phone_number: "0000-123456",
                                 created_at: "2012-05-04 18:17:04",
                                 community_id: community1.id)

    FactoryGirl.create(:community_membership,
                        person: person1,
                        community: community1,
                        admin: 1,
                        consent: "test_consent0.1",
                        last_page_load_date: DateTime.now,
                        status: "accepted" )

    @request.host = "#{community1.ident}.lvh.me"
    @request.env[:current_marketplace] = community1
  end

  it "redirects back to original community's domain" do
    post :create, params: {:person  => {:login => "testpersonusername", :password => "testi"}}
    expect(response).to redirect_to "http://#{@request.host}/"
  end
end
