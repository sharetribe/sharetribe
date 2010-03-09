require 'workling/remote/invokers/base'

#
#  A basic polling invoker. 
#  
module Workling
  module Remote
    module Invokers
      class BasicPoller < Workling::Remote::Invokers::Base
        
        #
        #  set up client, sleep time
        #
        def initialize(routing, client_class)
          super
        end
        
        #
        #  Starts main Invoker Loop. The invoker runs until stop() is called. 
        #
        def listen
          connect do
            loop_routes do |route|
              if args = @client.retrieve(route)
                run(route, args)
              end
            end
          end
        end
        
        #
        #  Gracefully stops the Invoker. The currently executing Jobs should be allowed
        #  to finish. 
        #
        def stop
          @shutdown = true
        end
      end
    end
  end
end