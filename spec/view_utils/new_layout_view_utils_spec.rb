require 'spec_helper'

describe NewLayoutViewUtils do
  before do
    allow(NewLayoutViewUtils).to receive(:published_features).and_return(
      [
        { title: "Foo",
          name: :foo
        },
        { title: "Bar",
          name: :bar
        },
        { title: "Wat",
          name: :wat
        }
      ])

    allow(NewLayoutViewUtils).to receive(:experimental_features).and_return({})
  end

  describe "#features" do
    person_id = "xyz"
    community_id = 123

    context "when features are enabled for person and community" do
      before do
        person_features = FeatureFlagService::Store::FeatureFlag::PersonFlag.call(
          {
            person_id: person_id,
            features: [:foo, :bar].to_set
          }
        )

        community_features = FeatureFlagService::Store::FeatureFlag::CommunityFlag.call(
          {
            community_id: community_id,
            features: [:wat].to_set
          }
        )

        allow(FeatureFlagService::API::Api.features).to receive(:get_for_person)
          .with({community_id: community_id, person_id: person_id}).and_return(Result::Success.new(person_features))
        allow(FeatureFlagService::API::Api.features).to receive(:get_for_community)
          .with({community_id: community_id}).and_return(Result::Success.new(community_features))
      end

      it "should return list of feature flags with corresponding features enabled for person and community" do
        expect(NewLayoutViewUtils.features(community_id, person_id, false, true)).to eql([
          { title: "Foo",
            name: :foo,
            enabled_for_user: true,
            enabled_for_community: false,
            required_for_user: false,
            required_for_community: false
          },
          { title: "Bar",
            name: :bar,
            enabled_for_user: true,
            enabled_for_community: false,
            required_for_user: false,
            required_for_community: false
          },
          { title: "Wat",
            name: :wat,
            enabled_for_user: false,
            enabled_for_community: true,
            required_for_user: false,
            required_for_community: false
          }
        ])
      end
    end

    context "when no features are enabled for person or community" do
      before do
        person_features = FeatureFlagService::Store::FeatureFlag::PersonFlag.call(
          {
            person_id: person_id,
            features: Set.new
          }
        )

        community_features = FeatureFlagService::Store::FeatureFlag::CommunityFlag.call(
          {
            community_id: community_id,
            features: Set.new
          }
        )

        allow(FeatureFlagService::API::Api.features).to receive(:get_for_person)
          .with({community_id: community_id, person_id: person_id}).and_return(Result::Success.new(person_features))
        allow(FeatureFlagService::API::Api.features).to receive(:get_for_community)
          .with({community_id: community_id}).and_return(Result::Success.new(community_features))
      end

      it "should return list of feature flags with no features enabled" do
        expect(NewLayoutViewUtils.features(community_id, person_id, false, true)).to eql([
          { title: "Foo",
            name: :foo,
            enabled_for_user: false,
            enabled_for_community: false,
            required_for_user: false,
            required_for_community: false
          },
          { title: "Bar",
            name: :bar,
            enabled_for_user: false,
            enabled_for_community: false,
            required_for_user: false,
            required_for_community: false
          },
          { title: "Wat",
            name: :wat,
            enabled_for_user: false,
            enabled_for_community: false,
            required_for_user: false,
            required_for_community: false
          }
        ])
      end
    end
  end

  describe "#enabled_features" do
    context "when features are enabled" do
      it "returns a list of those as symbols" do
        feature_params = {
          foo: "true",
          bar: "true",
          invalid: "value"
        }
        expect(NewLayoutViewUtils.enabled_features(feature_params))
          .to eql([:foo, :bar])
      end
    end

    context "when an empty hash is passed as params" do
      it "returns an empty list" do
        expect(NewLayoutViewUtils.enabled_features({}))
          .to eql([])
      end
    end

    context "when invalid features are passed as params" do
      it "thise should not be returned" do
        feature_params = {
          "foo" => "true",
          "bar" => "true",
          "invalid" => "true"
        }
        expect(NewLayoutViewUtils.enabled_features(feature_params))
          .to eql([:foo, :bar])
      end
    end
  end

  describe "#resolve_disabled" do
    it "returns list of features that are not given as parameter" do
      expect(NewLayoutViewUtils.resolve_disabled([:foo, :bar]))
        .to eql([:wat])
      expect(NewLayoutViewUtils.resolve_disabled([]))
        .to eql([:foo, :bar, :wat])
    end
  end
end
