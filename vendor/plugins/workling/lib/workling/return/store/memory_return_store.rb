require 'workling/return/store/base'

#
#  Stores directly into memory. This is for tests only - not for production use. aight?
#
module Workling
  module Return
    module Store
      class MemoryReturnStore < Base
        attr_accessor :sky
        
        def initialize
          self.sky = {}
        end
        
        def set(key, value)
          self.sky[key] = value
        end
        
        def get(key)
          self.sky.delete(key)
        end
      end
    end
  end
end