require 'spec_helper'

describe I18n::Backend::CommunityBackend do

  before(:each) do
    @backend = I18n.backend
    I18n.backend = I18n::Backend::CommunityBackend.new({}) # Hash as an empty key-value store

    I18n.backend.set_community!(1)
    I18n.backend.store_translations(:en, {foo: "bar"})
    I18n.backend.store_translations(:fi, {foo: "baari"})

    I18n.backend.set_community!(2)
    I18n.backend.store_translations(:en, {foo: "baz"})
    I18n.backend.store_translations(:fi, {foo: "baazi"})
  end

  after(:each) do
    # clean up
    I18n.backend = @backend
  end

  it "stores and looks translations per community" do
    I18n.backend.set_community!(1)
    expect(I18n.translate("foo", locale: :en)).to eq("bar")
    expect(I18n.translate("foo", locale: :fi)).to eq("baari")

    I18n.backend.set_community!(2)
    expect(I18n.translate("foo", locale: :en)).to eq("baz")
    expect(I18n.translate("foo", locale: :fi)).to eq("baazi")
  end

  it "does nothing if community is nil" do
    I18n.backend.set_community!(nil)
    expect(I18n.translate("foo", locale: :fi)).to eq("translation missing: fi.foo")
  end

end
