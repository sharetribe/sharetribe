# encoding: utf-8

require 'spec_helper'

describe IntApi::MarketplacesController do
  describe "#create" do
    it "should creat a marketplace and an admin user" do
      post :create, {admin_email: "eddie.admin@example.com",
                     admin_first_name: "Eddie",
                     admin_last_name: "Admin",
                     admin_password: "secret_word",
                     marketplace_country: "fi",
                     marketplace_language: "fi",
                     marketplace_name: "ImaginationTraders",
                     marketplace_type: "product"}

      response.status.should == 201

      c = Community.find_by_name("ImaginationTraders")
      expect(c).to_not be_nil
      #expect(c.country).to eql "fi"
      expect(c.locales.first).to eql "fi"
      expect(c.name).to eql "ImaginationTraders"
      expect(c.domain).to eql "imaginationtraders"

      p = c.admins.first
      expect(p).to_not be_nil
      expect(p.given_name).to eql "Eddie"
      expect(p.family_name).to eql "Admin"
      expect(p.locale).to eql "fi"
      expect(p.emails.first.address).to eql "eddie.admin@example.com"


    end
  end
end
