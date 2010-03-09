#
#  Basic interface for getting and setting Data which needs to be passed between Workers and
#  client code. 
#
module Workling
  module Return
    module Store
      mattr_accessor :instance
      
      # set a value in the store with the given key. delegates to the returnstore. 
      def self.set(key, value)
        self.instance.set(key, value)
      end
      
      # get a value from the store. this should be destructive. delegates to the returnstore. 
      def self.get(key)
        self.instance.get(key)
      end
      
      #
      #  Base Class for Return Stores. Subclasses need to implement set and get. 
      #
      class Base
        
        # set a value in the store with the given key. 
        def set(key, value)
          raise NotImplementedError.new("set(key, value) not implemented in #{ self.class }")
        end
      
        # get a value from the store. this should be destructive.
        def get(key)
          raise NotImplementedError.new("get(key) not implemented in #{ self.class }")
        end
      end
    end
  end
end