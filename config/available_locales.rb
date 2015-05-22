# coding: utf-8
module Sharetribe

  # Format: [name, identifier, language, region, fallback identifier]
  #
  # language format: ISO 639-1, two letters, lowercase
  # region format: ISO 3166, two letters, uppercase
  # fallbacks: should not include US English, which is a last default fallback for each language

  AVAILABLE_LOCALES = [
    ["English",             "en",    "en", "US", nil], # English (United States)
    ["English",             "en-GB", "en", "GB", nil], # English (United Kingdom)
    ["English",             "en-AU", "en", "AU", nil], # English (Australia)
    ["Suomi",               "fi",    "fi", "FI", nil], # Finnish (Finland)
    ["Pусский",             "ru",    "ru", "RU", nil], # Russian (Russia)
    ["Nederlands",          "nl",    "nl", "NL", nil], # Dutch (Netherlands)
    ["Ελληνικά",            "el",    "el", "GR", nil], # Greek (Greece)
    ["Kiswahili",           "sw",    "sw", "KE", nil], # Swahili (Kenya)
    ["Română",              "ro",    "ro", "RO", nil], # Romanian (Romania)
    ["Français",            "fr",    "fr", "FR", nil], # French (France)
    ["Français",            "fr-CA", "fr", "CA", "fr"], # French (Canada)
    ["中文",                "zh",    "zh", "CN", nil], # Chinese (China)
    ["Español",             "es",    "es", "CL", "es-ES"], # Spanish (Chile)
    ["Español",             "es-ES", "es", "ES", nil], # Spanish (Spain)
    ["Catalan",             "ca",    "ca", "ES", nil], # Catalan (Spain)
    ["Tiếng Việt",          "vi",    "vi", "VN", nil], # Vietnamese (Vietnam)
    ["Deutsch",             "de",    "de", "DE", nil], # German (Germany)
    ["Svenska",             "sv",    "sv", "SE", nil], # Swedish (Sweden)
    ["Italiano",            "it",    "it", "IT", nil], # Italian (Italy)
    ["Hrvatski",            "hr",    "hr", "HR", nil], # Croatian (Croatia)
    ["Português do Brasil", "pt-BR", "pt", "BR", nil], # Portuguese (Brazil)
    ["Dansk",               "da-DK", "da", "DK", nil], # Danish (Denmark)
    ["Turkish",             "tr-TR", "tr", "TR", nil], # Turkish (Turkey)
    ["日本語",               "ja",    "ja", "JP", nil], # Japanese (Japan)
    ["Norsk",               "nb",    "nb", "NO", nil], # Norwegian Bokmål (Norway)
    ["Polski",              "pl",    "pl", "PL", nil], # Polish (Poland)
    ["ភាសាខ្មែ",               "km-KH", "km", "KH", nil], # Khmer (Cambodia)
    ["Bahasa Malaysia",     "ms-MY", "ms", "MY", nil], # Malay (Malaysia)
    ["íslenska",            "is",    "is", "IS", nil], # Icelandic (Iceland)
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
