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
      c.should_not be_nil

      p = c.admins.first
      p.should_not be_nil
      p.given_name.should == "Eddie"
      p.family_name.should == "Admin"


    end
  end
end
