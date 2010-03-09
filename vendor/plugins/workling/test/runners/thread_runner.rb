require 'workling/remote/runners/base'

#
#  Spawns a Thread. Used for Tests only, to simulate a remote runner more realistically. 
#
module Workling
  module Remote
    module Runners
      class ThreadRunner < Workling::Remote::Runners::Base
        
        # spawns a thread. 
        def run(clazz, method, options = {})
          Thread.new {
            dispatch!(clazz, method, options) 
          }
                    
          return nil
        end
      end
    end
  end
end