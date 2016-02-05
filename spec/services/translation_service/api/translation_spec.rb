require "spec_helper"
describe TranslationService::API::Translations do

  TranslationsAPI = TranslationService::API::Api.translations

  before(:each) do
    @community_id = 88 # cucumber loads test data for existing test communities
    @translation_key1 = "027268a5-abbf-4191-b6bd-b1e7569b361f"
    @translation_key2 = "blaa-blaa-blaa"
    @locale_en = "en"
    @translation_en = "aa en"
    @locale_fi = "fi-FI"
    @translation_fi = "aa fi"
    @locale_sv = "sv-SE"
    @translations1 =
      [ { locale: @locale_en,
          translation: @translation_en
        },
        { locale: @locale_fi,
          translation: @translation_fi
        }
      ]
    @translations_with_keys =
      @translations1.map { |translation|
        {translation_key: @translation_key1}.merge(translation)
      }
    @translations_groups =
      [ { translation_key: @translation_key1,
          translations: @translations1
        }
      ]
    @translation_groups_with_keys =
      [ { translation_key: @translation_key1,
          translations: @translations_with_keys
        }
      ]
    @creation_hash =
      { community_id: @community_id,
        translation_groups: @translations_groups
      }

  end


  it "POST request with only community_id" do
    expect { TranslationsAPI.create(@community_id) }.to raise_error(ArgumentError)
  end

  it "POST request with community_id and wrong params" do
    expect { TranslationsAPI.create(@community_id, {foo: :bar}) }.to raise_error(ArgumentError)
  end

  it "POST request with community_id and wrong structure in params" do
    expect { TranslationsAPI.create(@community_id, [translations: [{locale: @locale_sv}] ]) }.to raise_error(ArgumentError)
  end

  it "POST request with community_id and correct params" do
    result = TranslationsAPI.create(@community_id, @translations_groups)
    expect(result[:success]).to eq(true)
    expect(result[:data]).to eq(@translation_groups_with_keys)
  end


  it "GET request with only community_id" do
    TranslationsAPI.create(@community_id, @translations_groups)
    result = TranslationsAPI.get(@community_id)
    expect(result[:success]).to eq(true)
    expect(result[:data]).to eq(@translations_with_keys)
  end

  it "GET request with community_id and translation_keys" do
    TranslationsAPI.create(@community_id, @translations_groups)
    result = TranslationsAPI.get(@community_id, translation_keys: [@translation_key1])
    expect(result[:success]).to eq(true)
    expect(result[:data]).to eq(@translations_with_keys)
  end

  it "GET request with community_id and locales" do
    TranslationsAPI.create(@community_id, @translations_groups)
    result = TranslationsAPI.get(@community_id, locales: [@locale_en, @locale_fi])
    expect(result[:success]).to eq(true)
    expect(result[:data]).to eq(@translations_with_keys)
  end

  it "GET request with community_id, locales, and fallback_locale" do
    TranslationsAPI.create(@community_id, @translations_groups)

    locale_sv_missing_fallback =
      { translation_key: @translation_key1,
        locale: @locale_en,
        translation: @translation_en,
        warn: :TRANSLATION_LOCALE_MISSING
      }

    result = TranslationsAPI.get(@community_id, {
      locales: [@locale_sv],
      fallback_locale: @locale_en
    })
    expect(result[:success]).to eq(true)
    expect(result[:data]).to eq([locale_sv_missing_fallback])
  end


  it "GET request with only community_id, translation_keys and locales" do
    TranslationsAPI.create(@community_id, @translations_groups)
    locale_sv_missing_fallback =
      { translation_key: @translation_key1,
        locale: @locale_sv,
        translation: nil,
        error: :TRANSLATION_LOCALE_MISSING
      }
    key2_missing_errors = [@locale_en, @locale_fi, @locale_sv].map { |locale|
      { translation_key: @translation_key2,
        locale: locale,
        translation: nil,
        error: :TRANSLATION_KEY_MISSING
      }
    }
    expected_with_fallbacks = @translations_with_keys
      .clone
      .push(locale_sv_missing_fallback)
      .concat(key2_missing_errors)

    result = TranslationsAPI.get(@community_id, {
      translation_keys: [@translation_key1, @translation_key2],
      locales: [@locale_en, @locale_fi, @locale_sv]
      })

    expect(result[:success]).to eq(true)
    expect(result[:data]).to eq(expected_with_fallbacks)
  end

  it "GET request with only community_id, translation_keys, locales, and fallback_locale" do
    TranslationsAPI.create(@community_id, @translations_groups)
    locale_sv_missing_fallback =
      { translation_key: @translation_key1,
        locale: @locale_en,
        translation: @translation_en,
        warn: :TRANSLATION_LOCALE_MISSING
      }
    key2_missing_errors = [@locale_en, @locale_fi, @locale_sv].map { |locale|
      { translation_key: @translation_key2,
        locale: locale,
        translation: nil,
        error: :TRANSLATION_KEY_MISSING
      }
    }
    expected_with_fallbacks = @translations_with_keys
      .clone
      .push(locale_sv_missing_fallback)
      .concat(key2_missing_errors)

    result = TranslationsAPI.get(@community_id, {
      translation_keys: [@translation_key1, @translation_key2],
      locales: [@locale_en, @locale_fi, @locale_sv],
      fallback_locale: @locale_en
      })

    expect(result[:success]).to eq(true)
    expect(result[:data]).to eq(expected_with_fallbacks)
  end

  it "GET request with only community_id, and wrong params" do
    TranslationsAPI.create(@community_id, @translations_groups)
    result = TranslationsAPI.get(@community_id, {foo: :bar})
    expect(result[:success]).to eq(true)
    expect(result[:data]).to eq(@translations_with_keys)
  end


  it "DELETE request with only community_id" do
    TranslationsAPI.create(@community_id, @translations_groups)
    expect { TranslationsAPI.delete(@community_id) }.to raise_error(ArgumentError)
  end

  it "DELETE request with only community_id with wrong params" do
    TranslationsAPI.create(@community_id, @translations_groups)
    expect { TranslationsAPI.delete(@community_id, {foo: :bar}) }.to raise_error(ArgumentError)
  end

  it "DELETE request with only community_id with correct params" do
    TranslationsAPI.create(@community_id, @translations_groups)
    result = TranslationsAPI.delete(@community_id, [@translation_key1])
    expect(result[:success]).to eq(true)
    expect(result.members.include?(:error_msg)).to be(false)
    expect(result[:data]).to eq(@translations_with_keys)
  end


end
