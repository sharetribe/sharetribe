require 'spec_helper'

describe NewLayoutViewUtils do

  TEST_FEATURES = [
    { title: "Foo",
      name: :foo
    },
    { title: "Bar",
      name: :bar
    },
    { title: "Wat",
      name: :wat
    }
  ]

  it "#features" do
    stub_const("NewLayoutViewUtils::FEATURES", TEST_FEATURES)

    allow(FeatureFlagHelper).to receive(:feature_enabled_for_user?)
      .with(:foo).and_return(true)
    allow(FeatureFlagHelper) .to receive(:feature_enabled_for_user?)
      .with(:bar).and_return(true)
    allow(FeatureFlagHelper) .to receive(:feature_enabled_for_user?)
      .with(:wat).and_return(false)
    allow(FeatureFlagHelper).to receive(:feature_enabled_for_community?)
      .with(:foo).and_return(false)
    allow(FeatureFlagHelper) .to receive(:feature_enabled_for_community?)
      .with(:bar).and_return(false)
    allow(FeatureFlagHelper) .to receive(:feature_enabled_for_community?)
      .with(:wat).and_return(true)

    expect(NewLayoutViewUtils.features).to eql([
        { title: "Foo",
          name: :foo,
          enabled_for_user: true,
          enabled_for_community: false
        },
        { title: "Bar",
          name: :bar,
          enabled_for_user: true,
          enabled_for_community: false
        },
        { title: "Wat",
          name: :wat,
          enabled_for_user: false,
          enabled_for_community: true
        }
      ])
  end

  it "#enabled_features" do
    feature_params = {
      foo: "true",
      bar: "true",
      invalid: "value"
    }

    expect(NewLayoutViewUtils.enabled_features(feature_params))
      .to eql([:foo, :bar])
    expect(NewLayoutViewUtils.enabled_features({}))
      .to eql([])
  end

  it "#resolve_disabled" do
    stub_const("NewLayoutViewUtils::FEATURES", TEST_FEATURES)

    expect(NewLayoutViewUtils.resolve_disabled([:foo, :bar]))
      .to eql([:wat])
    expect(NewLayoutViewUtils.resolve_disabled([]))
      .to eql([:foo, :bar, :wat])
  end
end
