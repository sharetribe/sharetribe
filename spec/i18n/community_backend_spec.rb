require 'spec_helper'

describe I18n::Backend::CommunityBackend do

  before(:each) do
    @backend = I18n.backend
    I18n.backend = I18n::Backend::CommunityBackend.new({}) # Hash as an empty key-value store
  end

  after(:each) do
    # clean up
    I18n.backend = @backend
  end

  default_locales = [:en, :fi]

  it "stores and looks translations per community" do
    I18n.backend.set_community!(1, default_locales)
    I18n.backend.store_translations(:en, {foo: "bar"})
    I18n.backend.store_translations(:fi, {foo: "baari"})

    expect(I18n.translate("foo", locale: :en)).to eq("bar")
    expect(I18n.translate("foo", locale: :fi)).to eq("baari")

    I18n.backend.set_community!(2, default_locales)
    I18n.backend.store_translations(:en, {foo: "baz"})
    I18n.backend.store_translations(:fi, {foo: "baazi"})
    expect(I18n.translate("foo", locale: :en)).to eq("baz")
    expect(I18n.translate("foo", locale: :fi)).to eq("baazi")
  end

  it "optionally doesn't clear stored translations on community change" do
    I18n.backend.set_community!(1, default_locales)
    I18n.backend.store_translations(:en, {foo: "bar"})
    I18n.backend.set_community!(2, default_locales, clear: false)
    I18n.backend.store_translations(:en, {foo: "baz"})

    expect(I18n.translate("foo", locale: :en)).to eq("baz")

    I18n.backend.set_community!(1, default_locales, clear: false)
    expect(I18n.translate("foo", locale: :en)).to eq("bar")
  end

  it "raises error if community is nil" do
    I18n.backend.set_community!(nil, default_locales)
    expect{ I18n.backend.store_translations(:en, {foo: "bar"}) }
      .to raise_error
  end

  it "falls back to another locale in use in case translation is not available" do
    all_locales = [:fi, :en]
    I18n.backend.set_community!(1, all_locales)
    I18n.backend.store_translations(:fi, {foo: "baari"})

    expect(I18n.translate("foo", locale: :en)).to eq("baari")
  end

  it "fails nicely in case no translation is available" do
    all_locales = [:fi, :en]
    I18n.backend.set_community!(1, all_locales)
    I18n.backend.store_translations(:fi, {foo: "baari"})

    expect(I18n.translate("poo", locale: :en)).to start_with("translation missing")
  end

end
