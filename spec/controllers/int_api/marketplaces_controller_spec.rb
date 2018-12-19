# encoding: utf-8

require 'spec_helper'

# Override the API with test API
require_relative '../../services/plan_service/api/api'

describe IntApi::MarketplacesController, type: :controller do

  before(:each) do
    PlanService::API::Api.reset!
    PlanService::API::Api.set_environment({active: true})
  end

  after(:each) do
    PlanService::API::Api.reset!
    PlanService::API::Api.set_environment({active: false})
  end

  def expect_trial_plan(cid)
    # Create trial plan
    plan = PlanService::API::Api.plans.get_current(community_id: cid).data
    expect(plan[:expires_at]).not_to eq(nil)
  end

  describe "#create" do
    it "should create a marketplace and an admin user" do
      post :create, params: { admin_email: "eddie.admin@example.com", 
                     admin_first_name: "Eddie",
                     admin_last_name: "Admin",
                     admin_password: "secret_word",
                     marketplace_country: "FI",
                     marketplace_language: "fi",
                     marketplace_name: "ImaginationTraders",
                     marketplace_type: "product"}

      expect(response.status).to eql 201

      r = JSON.parse(response.body)
      expect(r["marketplace_url"]).to eql "http://imaginationtraders.#{APP_CONFIG.domain}/en/admin/getting_started_guide?auth=#{AuthToken.last.token}"

      c = Community.where(ident: "imaginationtraders").first
      expect(c).to_not be_nil
      expect(c.country).to eql "FI"
      expect(c.locales.first).to eql "fi"
      expect(c.name("fi")).to eql "ImaginationTraders"
      expect(c.ident).to eql "imaginationtraders"
      s = c.shapes.first
      expect(s.price_enabled).to eql true
      expect(s.units.empty?).to eql false

      default_per_unit = {kind: "quantity", name_tr_key: nil, quantity_selector: "number", selector_tr_key: nil, unit_type: "unit"}
      expect(s.units.first).to eql default_per_unit

      payment_settings = TransactionService::API::Api.settings.get_active_by_gateway(community_id: c.id, payment_gateway: :paypal)
      expect(payment_settings[:data][:payment_gateway]).to eql :paypal
      expect(payment_settings[:data][:payment_process]).to eql :preauthorize

      p = c.admins.first
      expect(p).to_not be_nil
      expect(p.given_name).to eql "Eddie"
      expect(p.family_name).to eql "Admin"
      expect(p.username).to eql "eddiea"
      expect(p.locale).to eql "fi"
      expect(p.emails.first.address).to eql "eddie.admin@example.com"

      expect_trial_plan(c.id)
    end

    it "should handle emails starting with info@" do
      post :create, params: { admin_email: "info@example.com", 
                     admin_first_name: "Eddiè",
                     admin_last_name: "Admin",
                     admin_password: "secret_word",
                     marketplace_country: "FI",
                     marketplace_language: "fi",
                     marketplace_name: "ImaginationTraders",
                     marketplace_type: "product"}

      expect(response.status).to eq(201)

      r = JSON.parse(response.body)
      expect(r["marketplace_url"]).to eql "http://imaginationtraders.#{APP_CONFIG.domain}/en/admin/getting_started_guide?auth=#{AuthToken.last.token}"

      c = Community.where(ident: "imaginationtraders").first
      expect(c).to_not be_nil
      expect(c.country).to eql "FI"
      expect(c.locales.first).to eql "fi"
      expect(c.name("fi")).to eql "ImaginationTraders"
      expect(c.ident).to eql "imaginationtraders"
      s = c.shapes.first
      expect(s.price_enabled).to eql true
      expect(s.units.empty?).to eql false

      p = c.admins.first
      expect(p).to_not be_nil
      expect(p.given_name).to eql "Eddiè"
      expect(p.family_name).to eql "Admin"
      expect(p.username).to eql "eddiea"
      expect(p.locale).to eql "fi"
      expect(p.emails.first.address).to eql "info@example.com"

      expect_trial_plan(c.id)
    end

    it "should handle short emails like fo@barbar.com" do
      post :create, params: { admin_email: "fo@example.com", 
                     admin_first_name: "Eddie_",
                     admin_last_name: "Admin",
                     admin_password: "secret_word",
                     marketplace_country: "FI",
                     marketplace_language: "fi",
                     marketplace_name: "ImaginationTraders",
                     marketplace_type: "product"}

      expect(response.status).to eq(201)

      r = JSON.parse(response.body)
      expect(r["marketplace_url"]).to eql "http://imaginationtraders.#{APP_CONFIG.domain}/en/admin/getting_started_guide?auth=#{AuthToken.last.token}"

      c = Community.where(ident: "imaginationtraders").first
      expect(c).to_not be_nil
      expect(c.country).to eql "FI"
      expect(c.locales.first).to eql "fi"
      expect(c.name("fi")).to eql "ImaginationTraders"
      expect(c.ident).to eql "imaginationtraders"
      s = c.shapes.first
      expect(s.price_enabled).to eql true
      expect(s.units.empty?).to eql false

      p = c.admins.first
      expect(p).to_not be_nil
      expect(p.given_name).to eql "Eddie_"
      expect(p.family_name).to eql "Admin"
      expect(p.username).to eql "eddiea"
      expect(p.locale).to eql "fi"
      expect(p.emails.first.address).to eql "fo@example.com"

      expect_trial_plan(c.id)
    end

    it "should handle short first + last names" do
      post :create, params: { admin_email: "fo@example.com",
                     admin_first_name: "E",
                     admin_last_name: "McT",
                     admin_password: "secret_word",
                     marketplace_country: "FI",
                     marketplace_language: "fi",
                     marketplace_name: "ImaginationTraders",
                     marketplace_type: "product"}

      expect(response.status).to eq(201)

      r = JSON.parse(response.body)
      expect(r["marketplace_url"]).to eql "http://imaginationtraders.#{APP_CONFIG.domain}/en/admin/getting_started_guide?auth=#{AuthToken.last.token}"

      c = Community.where(ident: "imaginationtraders").first
      expect(c).to_not be_nil
      expect(c.country).to eql "FI"
      expect(c.locales.first).to eql "fi"
      expect(c.name("fi")).to eql "ImaginationTraders"
      expect(c.ident).to eql "imaginationtraders"
      s = c.shapes.first
      expect(s.price_enabled).to eql true
      expect(s.units.empty?).to eql false

      p = c.admins.first
      expect(p).to_not be_nil
      expect(p.given_name).to eql "E"
      expect(p.family_name).to eql "McT"
      expect(p.username).to eql "em1"
      expect(p.locale).to eql "fi"
      expect(p.emails.first.address).to eql "fo@example.com"

      expect_trial_plan(c.id)
    end

  end

  describe "#create_prospect_email" do
    it "should add given email as prospect email" do
      post :create_prospect_email, params: { :email => "something.not.used@example.com" }

      expect(response.status).to eql 200
      expect(response.body).to eql ""
      expect(ProspectEmail.last.email).to eql "something.not.used@example.com"
    end
    it "should return with an error when an email is not provided" do
      post :create_prospect_email, params: { }

      expect(response.status).to eql 400
      r = JSON.parse(response.body)
      expect(r[0]).to eql "Email missing from payload"
      expect(ProspectEmail.last).to be_nil
    end
  end
end
