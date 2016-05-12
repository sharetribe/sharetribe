# This file monkey-patches an open issue in I18n-js
#
# I18n-js doesn't work well with I18n::Backend::Chain backend
#
# See: https://github.com/fnando/i18n-js/issues/59

module I18n
  module JS

    def self.translations
      all_translations = {}
      selected_backends = []
      current_backend = ::I18n.backend

      case current_backend
      when I18n::Backend::Chain
        current_backend.backends.each do |backend_in_chain|
          if backend_in_chain.respond_to?(:translations, true)
            selected_backends << backend_in_chain
          end
        end
      else
        if current_backend.respond_to?(:translations, true)
          selected_backends = [current_backend]
        end
      end

      selected_backends.each do |selected_backend|
        selected_backend.instance_eval do
          # all `selected_backends` are `::I18n::Backend::Simple`
          if defined?(:initialized?) && defined?(:init_translations)
            init_translations unless initialized?
          end
        end
        all_translations.deep_merge!(selected_backend.send(:translations))
      end

      all_translations
    end

  end
end
