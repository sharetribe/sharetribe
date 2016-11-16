require 'pstore'

module PaypalService
  module API
    class FakePalPstore < FakePalStore

      class Namespace
        def initialize(store, namespace_path)
          @store = store
          @namespace_path = namespace_path

          @store.transaction do
            @store[@namespace_path] ||= {}
          end
        end

        def [](key)
          @store.transaction(true) do
            @store[@namespace_path][key]
          end
        end

        def []=(key, value)
          @store.transaction do
            @store[@namespace_path][key] = value
          end
        end
      end

      def initialize(file)
        @store = PStore.new(file)
      end

      def namespace(*namespace_path)
        Namespace.new(@store, namespace_path)
      end

      def reset!
        @store.transaction do
          @store.roots.each do |root|
            @store[root] = {}
          end
        end
      end
    end
  end
end
