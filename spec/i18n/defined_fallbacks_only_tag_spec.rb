require 'spec_helper'

# The I18n::Locale::Tag::Simple is NOT implemented by us. In that
# sense, this test is useless. It's here to demonstrate the difference
# between the default implementation and the `DefinedFallbacksOnly`
# implementation
describe I18n::Locale::Tag::Simple do
  it "returns the locale and splitted subparts" do
    tag_impl = I18n::Locale::Tag::Simple
    expect(tag_impl.tag("fi-FI-helsinki").self_and_parents.map(&:to_s)).to eq(["fi-FI-helsinki", "fi-FI", "fi"])
  end
end

describe I18n::Locale::Tag::DefinedFallbacksOnly do
  it "returns the locale as is" do
    tag_impl = I18n::Locale::Tag::DefinedFallbacksOnly
    expect(tag_impl.tag("fi-FI-helsinki").self_and_parents.map(&:to_s)).to eq(["fi-FI-helsinki"])
  end
end
