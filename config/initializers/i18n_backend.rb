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

      attr_accessor :community_id

      def store_translations(locale, data, options = {})
        return unless @community_id
        super(locale, wrap_community(data, @community_id), options)
      end

      def lookup(locale, key, scope = [], options = {})
        return unless @community_id
        super(locale, "#{@community_id}.#{key}", scope, options)
      end

      def self.instance
        self.translation_service_backend_instance ||= CommunityBackend.new({})
      end

      private

      def wrap_community(data, community_id)
        hash = {}
        hash[community_id] = data
        return hash
      end
    end
  end
end

I18n.backend = I18n::Backend::Chain.new(I18n::Backend::CommunityBackend.instance, I18n.backend)
