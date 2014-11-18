class TransactionMailer; end

describe UserService::API::Users do

  include UserService::API::Users

  include EmailSpec::Helpers
  include EmailSpec::Matchers

  PERSON_HASH = {
    given_name: "Raymond",
    family_name: "Xperiment",
    email: "Ray@example.com",
    password: "test",
    locale: "fr"
  }

  describe "#create_user" do

    it "should create a user" do
      u = create_user(PERSON_HASH)
      expect(u[:given_name]).to eql "Raymond"
      expect(Person.find_by_username("raymondx").family_name).to eql "Xperiment"
      expect(u[:locale]).to eql "fr"
    end

    it "should fail if email is taken" do
      u1 = create_user(PERSON_HASH)
      expect{create_user(PERSON_HASH)}.to raise_error(ArgumentError, /Email Ray@example.com is already in use/)
    end

  end

  describe "#create_user_with_membership" do

    before { ActionMailer::Base.deliveries = [] }

    before (:each) do
      expect(ActionMailer::Base.deliveries).to be_empty
      @community = FactoryGirl.create(:community)
    end

    it "should send the confirmation email" do
      u = create_user_with_membership(PERSON_HASH.merge({:locale => "en"}), @community.id)
      expect(ActionMailer::Base.deliveries).not_to be_empty

      email = ActionMailer::Base.deliveries.first
      expect(email).to have_subject "Confirmation instructions"
      # simple check that link to right community exists
      expect(email.body).to match @community.full_domain
      expect(email.body).to match "Sharetribe Team"
    end

    it "should send the confirmation email in right language" do
      u = create_user_with_membership(PERSON_HASH.merge({:locale => "fr"}), @community.id)
      expect(ActionMailer::Base.deliveries).not_to be_empty

      email = ActionMailer::Base.deliveries.first
      expect(email).to have_subject "Instructions de confirmation"
    end

  end


end
