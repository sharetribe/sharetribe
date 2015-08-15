require "spec_helper"

RSpec.describe FeatureFlagHelper, type: :helper do

  before(:each) do
    # Assign instance variable
    assign(:feature_flags, [:stable_feature].to_set)
  end


  describe "#feature_enabled?" do
    it "returns false for disabled feature" do
      expect(helper.feature_enabled?(:experimental_feature)).to eq(false)
    end

    it "returns true for enabled feature" do
      expect(helper.feature_enabled?(:stable_feature)).to eq(true)
    end
  end

  describe "#with_feature" do
    it "does not run block for disabled feature" do
      block_called = false
      helper.with_feature(:experimental_feature) { block_called = true }
      expect(block_called).to eq(false)
    end

    it "runs block for enabled feature" do
      block_called = false
      helper.with_feature(:stable_feature) { block_called = true }
      expect(block_called).to eq(true)
    end
  end
end
