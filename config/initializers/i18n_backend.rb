module I18n
  module Backend

    # A simple and minimal wrapper to KeyValue store, that allows
    # storing per community translations
    #
    # Usage:
    #
    # First set the community_id with `set_community!` method. After that, calls to
    # `store_translations` and `lookup` methods are sandboxed per community
    #
    # `instance` method returns the singleton instance
    #
    class CommunityBackend < KeyValue
      include Fallbacks

      class << self
        attr_accessor(:translation_service_backend_instance)
      end

      attr_reader :community_id

      def set_community!(community_id, clear: true)
        if community_id != @community_id
          @community_id = community_id

          # Clear store every time we switch community, this is not a cache
          @store = {} if clear
        end
      end

      def store_translations(locale, data, options = {})
        raise ArgumentError.new("Set community via set_community! before storing translations.") unless @community_id

        super(locale, {@community_id => data}, options)
      end

      def lookup(locale, key, scope = [], options = {})
        return unless @community_id
        super(locale, "#{@community_id}.#{key}", scope, options)
      end

      def self.instance
        self.translation_service_backend_instance ||= CommunityBackend.new({})
      end

    end
  end
end

I18n.backend = I18n::Backend::Chain.new(I18n::Backend::CommunityBackend.instance, I18n.backend)
