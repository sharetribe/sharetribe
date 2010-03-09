require 'eventmachine'
require 'workling/remote/invokers/base'

#
#  Subscribes the workers to the correct queues. 
# 
module Workling
  module Remote
    module Invokers
      class EventmachineSubscriber < Workling::Remote::Invokers::Base
        
        def initialize(routing, client_class)
          super
        end
        
        #
        #  Starts EM loop and sets up subscription callbacks for workers. 
        #
        def listen
          EM.run do
            connect do
              routes.each do |route|
                @client.subscribe(route) do |args|
                  run(route, args)
                end
              end
            end
          end
        end
                
        def stop
          EM.stop if EM.reactor_running?
        end
      end
    end
  end
end