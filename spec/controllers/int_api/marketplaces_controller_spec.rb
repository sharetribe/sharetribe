# encoding: utf-8

require 'spec_helper'

describe IntApi::MarketplacesController do
  describe "#create" do
    it "should creat a marketplace and an admin user" do
      post :create, {admin_email: "eddie.admin@example.com",
                     admin_first_name: "Eddie",
                     admin_last_name: "Admin",
                     admin_password: "secret_word",
                     marketplace_country: "FI",
                     marketplace_language: "fi",
                     marketplace_name: "ImaginationTraders",
                     marketplace_type: "product"}

      response.status.should == 201

      c = Community.find_by_name("ImaginationTraders")
      expect(c).to_not be_nil
      expect(c.country).to eql "fi"
      expect(c.locales.first).to eql "fi"
      expect(c.name).to eql "ImaginationTraders"
      expect(c.domain).to eql "imaginationtraders"
      expect(c.transaction_types.first.class).to eql Sell

      p = c.admins.first
      expect(p).to_not be_nil
      expect(p.given_name).to eql "Eddie"
      expect(p.family_name).to eql "Admin"
      expect(p.locale).to eql "fi"
      expect(p.emails.first.address).to eql "eddie.admin@example.com"


    end
  end

  describe "#check_email_availability" do
    it "should return correct availability info when email is available" do
      get :check_email_availability, {:email => "something.not.used@example.com" }

      expect(response.status).to eql 200
      r = JSON.parse(response.body)

      expect(r["email"]).to eql "something.not.used@example.com"
      expect(r["available"]).to eql true
    end

    it "should return correct availability info when email is not available" do

      FactoryGirl.create(:email, :address => "occupied@email.com")
      get :check_email_availability, {:email => "occupied@email.com"}

      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      puts r.to_yaml
      expect(r["email"]).to eql "occupied@email.com"
      expect(r["available"]).to eql false
    end

  end
end
