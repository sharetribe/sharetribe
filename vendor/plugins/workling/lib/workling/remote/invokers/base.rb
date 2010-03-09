#
#  Invokers are responsible for 
#
#      1. grabbing work off a job broker (such as a starling or rabbitmq server).
#      2. routing (mapping) that work onto the correct worker method. 
#      3.invoking the worker method, passing any arguments that came off the broker.
#
#   Invokers should implement their own concurrency strategies. For example, 
#   The there is a ThreadedPoller which starts a thread for each Worker class.
#
#   This base Invoker class defines the methods an Invoker needs to implement. 
#  
module Workling
  module Remote
    module Invokers
      class Base
        
        attr_accessor :sleep_time, :reset_time
        
        #
        #  call up with super in the subclass constructor.
        #
        def initialize(routing, client_class)
          @routing = routing
          @client_class = client_class
          @sleep_time = Workling.config[:sleep_time] || 2
          @reset_time = Workling.config[:reset_time] || 30
          @@mutex ||= Mutex.new
        end
        
        #
        #  Starts main Invoker Loop. The invoker runs until stop() is called. 
        #
        def listen
          raise NotImplementedError.new("Implement listen() in your Invoker. ")
        end        
        
        #
        #  Gracefully stops the Invoker. The currently executing Jobs should be allowed
        #  to finish. 
        #
        def stop
          raise NotImplementedError.new("Implement stop() in your Invoker. ")
        end
        
        # 
        #  Runs the worker method, given
        #
        #      type: the worker route
        #      args: the arguments to be passed into the worker method.
        #
        def run(type, args)
          worker = @routing[type]
          method = @routing.method_name(type)
          worker.dispatch_to_worker_method(method, args)
        end
        
        # returns the Workling::Base.logger
        def logger; Workling::Base.logger; end
        
        protected
        
          # handle opening and closing of client. pass code block to this method. 
          def connect
            @client = @client_class.new
            @client.connect
            
            begin
              yield
            ensure
              @client.close
              ActiveRecord::Base.verify_active_connections!
            end
          end

          #
          #  Loops through the available routes, yielding for each route. 
          #  This continues until @shutdown is set on this instance. 
          #
          def loop_routes
            while(!@shutdown) do
              ensure_activerecord_connection
              
              routes.each do |route|
                break if @shutdown
                yield route
              end
              
              sleep self.sleep_time
            end
          end

          #
          #  Returns the complete set of active routes
          #
          def routes
            @active_routes ||= Workling::Discovery.discovered.map { |clazz| @routing.queue_names_routing_class(clazz) }.flatten
          end
          
          # Thanks for this Brent! 
          #
          #     ...Just a heads up, due to how rails’ MySQL adapter handles this  
          #     call ‘ActiveRecord::Base.connection.active?’, you’ll need 
          #     to wrap the code that checks for a connection in in a mutex.
          #
          #     ....I noticed this while working with a multi-core machine that 
          #     was spawning multiple workling threads. Some of my workling 
          #     threads would hit serious issues at this block of code without 
          #     the mutex.            
          #
          def ensure_activerecord_connection
            @@mutex.synchronize do 
              unless ActiveRecord::Base.connection.active?  # Keep MySQL connection alive
                unless ActiveRecord::Base.connection.reconnect!
                  logger.fatal("Failed - Database not available!")
                  break
                end
              end
            end            
          end
      end
    end
  end
end