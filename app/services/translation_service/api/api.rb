module TranslationService::API
  class API
    class << self; attr_accessor :translations_api; end

    def self.translations
      self.translations_api ||= TranslationService::API::Translations.new
    end
  end
end
