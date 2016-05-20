module I18n
  module Backend

    # A simple and minimal wrapper to KeyValue store, that allows
    # storing per community translations.
    #
    # Does NOT include the default Fallbacks module but instead
    # implements its own fallback logic in `lookup`, which doesn't
    # rely on the fallback mapping.
    #
    # Usage:
    #
    # First set the community_id with `set_community!` method. After that, calls to
    # `store_translations` and `lookup` methods are sandboxed per community
    #
    # `instance` method returns the singleton instance
    #
    class CommunityBackend < KeyValue

      class << self
        attr_accessor(:translation_service_backend_instance)
      end

      attr_reader :community_id

      def set_community!(community_id, locales_in_use, clear: true)
        old_values = {
          community_id: @community_id,
          locales_in_use: Maybe(@locales_in_use)[@community_id].or_else(nil)
        }

        if clear || community_id != @community_id
          @community_id = community_id

          # Clear store every time we switch community, this is not a cache
          if clear
            @store = {}
            @locales_in_use = {}
            @locales_with_translations = {}
            @locales_fallback_preference_order = {}
          end
          @locales_in_use = {} unless @locales_in_use
          @locales_in_use[community_id] = locales_in_use
          @locales_with_translations = {} unless @locales_with_translations
          @locales_with_translations[community_id] = Set.new
          @locales_fallback_preference_order = {} unless @locales_fallback_preference_order
          @locales_fallback_preference_order.default = []
        end

        old_values
      end

      def store_translations(locale, data, options = {})
        raise ArgumentError.new("Set community via set_community! before storing translations.") unless @community_id
        @locales_with_translations[@community_id] << locale
        @locales_fallback_preference_order[@community_id] = [@locales_in_use[@community_id], @locales_with_translations[@community_id].to_a].flatten.uniq
        super(locale, {@community_id => data}, options)
      end

      def lookup(locale, key, scope = [], options = {})
        return unless @community_id
        [locale].concat(@locales_fallback_preference_order[@community_id]).uniq.each { |l|
          t = super(l, "#{@community_id}.#{key}", scope, options)
          return t if t
        }
        nil
      end

      def self.instance
        self.translation_service_backend_instance ||= CommunityBackend.new({})
      end

    end
  end
end

I18n.backend = I18n::Backend::Chain.new(I18n::Backend::CommunityBackend.instance, I18n.backend)
