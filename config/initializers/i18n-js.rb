# This file monkey-patches an open issue in I18n-js
#
# I18n-js doesn't work well with I18n::Backend::Chain backend
#
# See: https://github.com/fnando/i18n-js/issues/59

module I18n
  module JS

    # Returns a list of backends that are in use and respond to `translations`
    # method.
    #
    # In practice, the SimpleBackend is the only backend that responds to
    # the `translations` method.
    #
    def self.selected_backends
      current_backend = ::I18n.backend

      case current_backend
      when I18n::Backend::Chain
        current_backend.backends.select do |backend_in_chain|
          backend_in_chain.respond_to?(:translations, true)
        end
      else
        if current_backend.respond_to?(:translations, true)
          [current_backend]
        end
      end
    end

    def self.translations
      all_translations = {}

      selected_backends.each do |selected_backend|
        selected_backend.instance_eval do
          # all `selected_backends` are `::I18n::Backend::Simple`
          if defined?(:initialized?) && defined?(:init_translations)
            init_translations unless initialized?
          end
        end
        all_translations.deep_merge!(selected_backend.send(:translations))
      end

      all_translations.slice(*::I18n.available_locales)
    end

    class FallbackLocales
      def using_i18n_fallbacks_module?
        I18n::JS.selected_backends.any? do |backend|
          backend.class.included_modules.include?(I18n::Backend::Fallbacks)
        end
      end
    end
  end
end
