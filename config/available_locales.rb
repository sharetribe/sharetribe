module Sharetribe
  AVAILABLE_LOCALES = [
    ["English", "en"],
    ["English", "en-GB"],
    ["English", "en-AU"],
    ["Suomi", "fi"],
    ["Pусский", "ru"],
    ["Nederlands", "nl"],
    ["Ελληνικά", "el"],
    ["Kiswahili", "sw"],
    ["Română", "ro"],
    ["Français", "fr"],
    ["Français", "fr-CA"],
    ["中文", "zh"],
    ["Español", "es"],
    ["Español", "es-ES"],
    ["Catalan", "ca"],
    ["Tiếng Việt", "vi"],
    ["Deutsch", "de"],
    ["Svenska", "sv"],
    ["Italiano", "it"],
    ["Hrvatski", "hr"],
    ["Português do Brasil", "pt-BR"],
    ["Dansk", "da-DK"],
    ["Turkish", "tr-TR"],
    ["日本語", "ja"],
    ["Norsk", "nb"],
    ["Polski", "pl"],
    ["ភាសាខ្មែ","km-KH"],
    ["Bahasa Malaysia", "ms-MY"],
    ["íslenska", "is"],

    # Customization languages
    ["English", "en-qr"],
    ["English", "en-at"],
    ["French", "fr-at"]
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
    "fr-rc" => "fr"
  }

  REMOVED_LOCALES = REMOVED_LOCALE_FALLBACKS.keys.to_set
end
