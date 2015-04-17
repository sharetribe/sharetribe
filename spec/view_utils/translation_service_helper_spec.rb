# coding: utf-8
require 'spec_helper'

describe TranslationServiceHelper do

  it "#to_per_key_translations" do
    expect(TranslationServiceHelper.to_per_key_translations(
            { "foo" => { "en" => "en foo", "fi" => "fi foo"},
              "bar" => { "en" => "en bar", "fi" => "fi bar"} }))
      .to eq([{translation_key: "foo",
               translations: [ {locale: "en", translation: "en foo"},
                               {locale: "fi", translation: "fi foo"}]},
              {translation_key: "bar",
               translations: [ {locale: "en", translation: "en bar"},
                               {locale: "fi", translation: "fi bar"}] }])

    expect(TranslationServiceHelper.to_per_key_translations(
            { "foo" => { "en" => "en foo", "fi" => nil},
              "bar" => { "en" => "", "fi" => "fi bar"} }))
      .to eq([{translation_key: "foo",
               translations: [{locale: "en", translation: "en foo"}]},
              {translation_key: "bar",
               translations: [{locale: "fi", translation: "fi bar"}]}])
  end

end
