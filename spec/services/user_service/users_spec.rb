describe UserService::API::Users do
  include UserService::API::Users

  describe "#create" do
    it "should create a user" do
      pending
    end

    it "should fail if email is taken" do
      pending
      #expect(preauth_expires_at(five_days, three_days)).to eq(three_days)
    end

  end

  describe "#set_user_as_admin" do


    it "should set the user as admin of the given community" do
      pending
    end

  end


end
