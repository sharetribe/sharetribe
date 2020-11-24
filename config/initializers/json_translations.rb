# Load old-style JSON translations
#
# These translations will be inlined to the document so that JavaScript
# scripts can use these translations

module JSONTranslations

  module_function

  def load_all()
    @json_locales = {};
    Sharetribe::AVAILABLE_LOCALES.each { |locale|
      # Read the file and save the content as JSON string.
      # No need to parse it
      ident = locale[:ident]
      @json_locales[ident] = File.read(Rails.root.join("app/assets/javascripts/locales/#{ident}.json"))
    }
  end

  def get(ident)
    @json_locales[ident.to_s]
  end

end

JSONTranslations.load_all
