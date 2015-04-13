# coding: utf-8
require 'spec_helper'

describe FeatureFlagService::API::Features do

  let(:features) { FeatureFlagService::API::Api.features }
  let(:community_id) { 321 }

  context "#enable" do
    it "returns error if called with empty or nil features list" do
      expect(features.enable(community_id: community_id, features: []).success)
        .to eq(false)

      expect(features.enable(community_id: community_id, features: nil).success)
        .to eq(false)
    end

    it "enables the given supported feature" do
      res = features.enable(community_id: community_id, features: [:shape_ui])

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq([:shape_ui].to_set)
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

    it "disables the given supported feature" do
      features.enable(community_id: community_id, features: [:shape_ui])
      res = features.disable(community_id: community_id, features: [:shape_ui])

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq(Set.new)
    end

    it "does nothing if called with unknown feature" do
      features.enable(community_id: community_id, features: [:shape_ui])
      res = features.disable(community_id: community_id, features: [:foo_feature])

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq([:shape_ui].to_set)
    end
  end

  context "#get" do
    it "returns result with no features enabled when nothing recorded for a community" do
      res = features.get(community_id: community_id)

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq(Set.new)
    end

    it "returns enabled features as a set" do
      features.enable(community_id: community_id, features: [:shape_ui])
      res = features.get(community_id: community_id)

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq([:shape_ui].to_set)
    end
  end
end
