require 'spec_helper'

describe SettingsController do

  describe "GET 'profile'" do
    it "should be successful" do
      get 'profile'
      response.should be_success
    end
  end

  describe "GET 'notifications'" do
    it "should be successful" do
      get 'notifications'
      response.should be_success
    end
  end

end
