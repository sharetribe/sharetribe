# coding: utf-8
require 'spec_helper'

describe FeatureFlagService::API::Features do

  let(:test_flag) { :bar_feature }
  let(:features) { FeatureFlagService::API::Features.new(
    FeatureFlagService::Store::FeatureFlag.new(
    additional_flags: [test_flag]
  )) }
  let(:community_id) { 321 }
  let(:person_id) { "abc123" }

  context "#enable" do
    it "returns error if called with empty or nil features list" do
      expect(features.enable(community_id: community_id, features: []).success)
        .to eq(false)

      expect(features.enable(community_id: community_id, features: nil).success)
        .to eq(false)
    end

    it "enables the given supported feature for a person" do
      res = features.enable(community_id: community_id, person_id: person_id, features: [test_flag])

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq([test_flag].to_set)
    end

    it "enables the given supported feature for a community" do
      res = features.enable(community_id: community_id, features: [test_flag])

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq([test_flag].to_set)
    end

    it "does nothing if called with unknown feature" do
      res = features.enable(community_id: community_id, features: [:foo_feature])

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq(Set.new)
    end
  end

  context "#disable" do
    it "returns error if called with empty or nil features list" do
      expect(features.disable(community_id: community_id, features: []).success)
        .to eq(false)

      expect(features.disable(community_id: community_id, features: nil).success)
        .to eq(false)
    end

    it "disables the given supported community feature" do
      features.enable(community_id: community_id, features: [test_flag])
      res = features.disable(community_id: community_id, features: [test_flag])

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq(Set.new)
    end

    it "disables the given supported person feature" do
      features.enable(community_id: community_id, person_id: person_id, features: [test_flag])
      res = features.disable(community_id: community_id, person_id: person_id, features: [test_flag])

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq(Set.new)
    end

    it "does nothing if called with unknown feature" do
      features.enable(community_id: community_id, features: [test_flag])
      res = features.disable(community_id: community_id, features: [:foo_feature])

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq([test_flag].to_set)
    end
  end

  context "#get" do
    it "returns result with no features enabled when nothing recorded for a community" do
      res = features.get(community_id: community_id)

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq(Set.new)
    end

    it "returns result with no features enabled when nothing recorded for a person" do
      res = features.get(community_id: community_id, person_id: person_id)

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq(Set.new)
    end

    it "returns enabled features as a set for a community" do
      features.enable(community_id: community_id, features: [test_flag])
      res = features.get(community_id: community_id)

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq([test_flag].to_set)
    end

    it "returns enabled features as a set for a person" do
      features.enable(community_id: community_id, person_id: person_id, features: [test_flag])
      res = features.get(community_id: community_id, person_id: person_id)

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq([test_flag].to_set)
    end
  end

  context "#enabled?" do
    it "returns false when nothing is recorded for a community or a person" do
      res = features.enabled?(community_id: community_id, person_id: person_id, feature: test_flag)

      expect(res.success).to eq(true)
      expect(res.data).to eq(false)
    end

    it "returns true if a features is enabled for a community" do
      features.enable(community_id: community_id, features: [test_flag])
      res = features.enabled?(community_id: community_id, feature: test_flag)

      expect(res.success).to eq(true)
      expect(res.data).to eq(true)
    end

    it "returns true if a features is enabled for a person" do
      features.enable(community_id: community_id, person_id: person_id, features: [test_flag])
      res = features.enabled?(community_id: community_id, person_id: person_id, feature: test_flag)

      expect(res.success).to eq(true)
      expect(res.data).to eq(true)
    end
  end
end
