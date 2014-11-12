describe UserService::API::Users do

  include UserService::API::Users

  include EmailSpec::Helpers
  include EmailSpec::Matchers

  before (:each) do
    @person_hash = {person: {
        given_name: "Raymond",
        family_name: "Xperiment",
        email: "Ray@example.com",
        password: "test"
      },
      locale: "fr"
    }
  end

  describe "#create_user" do

    it "should create a user" do
      u = create_user(@person_hash)
      expect(u.given_name).to eql "Raymond"
      expect(Person.find_by_username("ray").family_name).to eql "Xperiment"
      expect(u.locale).to eql "fr"
    end

    it "should fail if email is taken" do
      u1 = create_user(@person_hash)
      expect{create_user(@person_hash)}.to raise_error(RuntimeError, /Email Ray@example.com is already in use/)
    end

  end

  describe "#create_user_with_membership" do

    before { ActionMailer::Base.deliveries = [] }

    it "should send the confirmation email" do
      expect(ActionMailer::Base.deliveries).to be_empty

      c = FactoryGirl.create(:community)
      u = create_user_with_membership(@person_hash, c.id)
      expect(ActionMailer::Base.deliveries).not_to be_empty

      email = ActionMailer::Base.deliveries.first
      expect(email).to have_subject "Confirmation instructions"
      # simple check that link to right community exists
      expect(email.body).to match c.full_domain

    end

  end


end
