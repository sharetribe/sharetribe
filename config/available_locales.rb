# coding: utf-8
module Sharetribe

  # Format: [name, identifier, language, region]
  #
  # language format: ISO 639-1, two letters, lowercase
  # region format: ISO 3166, two letters, uppercase

  AVAILABLE_LOCALES = [
    ["English",             "en",    "en", "US"], # English (United States)
    ["English",             "en-GB", "en", "GB"], # English (United Kingdom)
    ["English",             "en-AU", "en", "AU"], # English (Australia)
    ["Suomi",               "fi",    "fi", "FI"], # Finnish (Finland)
    ["Pусский",             "ru",    "ru", "RU"], # Russian (Russia)
    ["Nederlands",          "nl",    "nl", "NL"], # Dutch (Netherlands)
    ["Ελληνικά",            "el",    "el", "GR"], # Greek (Greece)
    ["Kiswahili",           "sw",    "sw", "KE"], # Swahili (Kenya)
    ["Română",              "ro",    "ro", "RO"], # Romanian (Romania)
    ["Français",            "fr",    "fr", "FR"], # French (France)
    ["Français",            "fr-CA", "fr", "CA"], # French (Canada)
    ["中文",                "zh",    "zh", "CN"], # Chinese (China)
    ["Español",             "es",    "es", "CL"], # Spanish (Chile)
    ["Español",             "es-ES", "es", "ES"], # Spanish (Spain)
    ["Catalan",             "ca",    "ca", "ES"], # Catalan (Spain)
    ["Tiếng Việt",          "vi",    "vi", "VN"], # Vietnamese (Vietnam)
    ["Deutsch",             "de",    "de", "DE"], # German (Germany)
    ["Svenska",             "sv",    "sv", "SE"], # Swedish (Sweden)
    ["Italiano",            "it",    "it", "IT"], # Italian (Italy)
    ["Hrvatski",            "hr",    "hr", "HR"], # Croatian (Croatia)
    ["Português do Brasil", "pt-BR", "pt", "BR"], # Portuguese (Brazil)
    ["Dansk",               "da-DK", "da", "DK"], # Danish (Denmark)
    ["Turkish",             "tr-TR", "tr", "TR"], # Turkish (Turkey)
    ["日本語",               "ja",    "ja", "JP"], # Japanese (Japan)
    ["Norsk",               "nb",    "nb", "NO"], # Norwegian Bokmål (Norway)
    ["Polski",              "pl",    "pl", "PL"], # Polish (Poland)
    ["ភាសាខ្មែ",               "km-KH", "km", "KH"], # Khmer (Cambodia)
    ["Bahasa Malaysia",     "ms-MY", "ms", "MY"], # Malay (Malaysia)
    ["íslenska",            "is",    "is", "IS"], # Icelandic (Iceland)

    # Customization languages
  ]
  WELL_TRANSLATED_LOCALES = [
    ["English", "en"],
    ["Français", "fr"],
    ["Español", "es-ES"],
    ["Português do Brasil", "pt-BR"],
    ["Norsk Bokmål", "nb"],
    ["Svenska", "sv"],
    ["Dansk", "da-DK"],
    ["Suomi", "fi"],
    ["Pусский", "ru"],
    ["Deutsch", "de"],
    ["Ελληνικά", "el"],
    ["Nederlands", "nl"],
    ["Turkish", "tr-TR"],
    ["中文", "zh"],
    ["日本語", "ja"],
    ["Italiano", "it"]
  ]

  REMOVED_LOCALE_FALLBACKS = {
    # removed 20.5.2015
    "de-bl" => "de",
    "de-rc" => "de",
    "en-bd" => "en",
    "en-bf" => "en",
    "en-bl" => "en",
    "en-cf" => "en",
    "en-rc" => "en",
    "en-sb" => "en",
    "en-ul" => "en",
    "en-un" => "en",
    "en-vg" => "en",
    "es-rc" => "es",
    "fr-bd" => "fr",
    "fr-rc" => "fr",

    # removed 21.5.2015
    "en-qr" => "en",
    "en-at" => "en",
    "fr-at" => "fr"
  }

  REMOVED_LOCALES = REMOVED_LOCALE_FALLBACKS.keys.to_set
end
