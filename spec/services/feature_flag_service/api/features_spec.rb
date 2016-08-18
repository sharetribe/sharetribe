# coding: utf-8
require 'spec_helper'

describe FeatureFlagService::API::Features do

  let(:test_flag) { :test_feature }
  let(:test_flag2) { :test_feature2 }
  let(:unknown_flag) { :unknown_feature }
  let(:features) { FeatureFlagService::API::Features.new(
    FeatureFlagService::Store::FeatureFlag.new(
    additional_flags: [test_flag, test_flag2]
  )) }
  let(:community_id) { 321 }
  let(:person_id) { "123" }

  context "#enable" do
    it "returns error if called with empty or nil features list" do
      expect(features.enable(community_id: community_id, features: []).success)
        .to eq(false)

      expect(features.enable(community_id: community_id, features: nil).success)
        .to eq(false)

      expect(features.enable(community_id: community_id, person_id: person_id, features: []).success)
        .to eq(false)

      expect(features.enable(community_id: community_id, person_id: person_id, features: nil).success)
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
      res_community = features.enable(community_id: community_id, features: [unknown_flag])

      expect(res_community.success).to eq(true)
      expect(res_community.data[:features]).to eq(Set.new)

      res_person = features.enable(community_id: community_id, person_id: person_id, features: [unknown_flag])

      expect(res_person.success).to eq(true)
      expect(res_person.data[:features]).to eq(Set.new)
    end
  end

  context "#disable" do
    it "returns error if called with empty or nil features list" do
      expect(features.disable(community_id: community_id, features: []).success)
        .to eq(false)

      expect(features.disable(community_id: community_id, features: nil).success)
        .to eq(false)

      expect(features.disable(community_id: community_id, person_id: person_id, features: []).success)
        .to eq(false)

      expect(features.disable(community_id: community_id, person_id: person_id, features: nil).success)
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
      res_community = features.disable(community_id: community_id, features: [unknown_flag])

      expect(res_community.success).to eq(true)
      expect(res_community.data[:features]).to eq([test_flag].to_set)

      features.enable(community_id: community_id, person_id: person_id, features: [test_flag])
      res_person = features.disable(community_id: community_id, person_id: person_id, features: [unknown_flag])

      expect(res_person.success).to eq(true)
      expect(res_person.data[:features]).to eq([test_flag].to_set)
    end
  end

  context "#get" do
    it "returns a result with no features enabled when nothing recorded for a community or a person" do
      res = features.get(community_id: community_id, person_id: person_id)

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq(Set.new)
    end

    it "returns a result with no features enabled when nothing recorded for a community" do
      res = features.get_for_community(community_id: community_id)

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq(Set.new)
    end

    it "returns a result with no features enabled when nothing recorded for a person" do
      res = features.get_for_person(community_id: community_id, person_id: person_id)

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq(Set.new)
    end

    it "returns enabled features as a set for a community" do
      features.enable(community_id: community_id, features: [test_flag])
      res = features.get_for_community(community_id: community_id)

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq([test_flag].to_set)
    end

    it "returns enabled features as a set for a person" do
      features.enable(community_id: community_id, person_id: person_id, features: [test_flag])
      res = features.get_for_person(community_id: community_id, person_id: person_id)

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq([test_flag].to_set)
    end

    it "returns enabled features as a set for a community and a person" do
      features.enable(community_id: community_id, features: [test_flag])
      features.enable(community_id: community_id, person_id: person_id, features: [test_flag2])
      res = features.get(community_id: community_id, person_id: person_id)

      expect(res.success).to eq(true)
      expect(res.data[:features]).to eq([test_flag, test_flag2].to_set)
    end
  end
end
