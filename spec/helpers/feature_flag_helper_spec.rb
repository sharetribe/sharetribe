require "spec_helper"

RSpec.describe FeatureFlagHelper, type: :helper do

  before(:each) do
    RequestStore.begin!
    RequestStore.store[:feature_flags] = [:stable_feature].to_set
  end

  after(:each) do
    RequestStore.end!
    RequestStore.clear!
  end


  describe "#feature_enabled?" do
    it "returns false for disabled feature" do
      expect(feature_enabled?(:experimental_feature)).to eq(false)
    end

    it "returns true for enabled feature" do
      expect(feature_enabled?(:stable_feature)).to eq(true)
    end
  end

  describe "#with_feature" do
    it "does not run block for disabled feature" do
      block_called = false
      with_feature(:experimental_feature) { block_called = true }
      expect(block_called).to eq(false)
    end

    it "runs block for enabled feature" do
      block_called = false
      with_feature(:stable_feature) { block_called = true }
      expect(block_called).to eq(true)
    end
  end

  describe "fetch_temp_flags" do
    let(:session) { {feature_flags: [:shipping].to_set} }
    let(:params) { {enable_feature: "booking"} }

    it "fetches temporary flags from session and params" do
      expect(fetch_temp_flags(true, params, session)).to eq [:shipping, :booking].to_set
    end

    it "returns empty set if not admin" do
      expect(fetch_temp_flags(false, params, session)).to eq [].to_set
    end
  end
end
