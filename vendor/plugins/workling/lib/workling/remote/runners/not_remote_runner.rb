require 'workling/remote/runners/base'

#
# directly dispatches to the worker method, in-process. options are first marshalled then dumped
# in order to simulate the sideeffects of a remote call.
#
module Workling
  module Remote
    module Runners
      class NotRemoteRunner < Workling::Remote::Runners::Base
        
        # directly dispatches to the worker method, in-process. options are first marshalled then dumped
        # in order to simulate the sideeffects of a remote call. 
        def run(clazz, method, options = {})
          options = Marshal.load(Marshal.dump(options)) # get this to behave more like the remote runners
          dispatch!(clazz, method, options) 
          
          return nil # nada. niente.
        end
      end
    end
  end
end
