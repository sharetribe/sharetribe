describe UserService::API::Users do
  include UserService::API::Users

  describe "#create_user" do
    before (:all) do
      @person_hash = {person: {
          given_name: "Raymond",
          family_name: "Xperiment",
          email: "Ray@example.com",
          password: "test"
        },
        locale: "fr"
      }
    end

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

  describe "#create_user_and_make_a_member_of_community" do


    it "should send the confirmation email" do
      pending
    end

  end


end
