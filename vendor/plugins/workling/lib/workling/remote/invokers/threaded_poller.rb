# -*- coding: utf-8 -*-
require 'workling/remote/invokers/base'

#
#  A threaded polling Invoker. 
# 
#  TODO: refactor this to make use of the base class. 
# 
module Workling
  module Remote
    module Invokers
      class ThreadedPoller < Workling::Remote::Invokers::Base
        
        cattr_accessor :sleep_time, :reset_time
      
        def initialize(routing, client_class)
          super
          
          ThreadedPoller.sleep_time = Workling.config[:sleep_time] || 2
          ThreadedPoller.reset_time = Workling.config[:reset_time] || 30
          
          @workers = ThreadGroup.new
          @mutex = Mutex.new
        end      
          
        def listen                
          # Allow concurrency for our tasks
          ActiveRecord::Base.allow_concurrency = true

          # Create a thread for each worker.
          Workling::Discovery.discovered.each do |clazz|
            logger.debug("Discovered listener #{clazz}")
            @workers.add(Thread.new(clazz) { |c| clazz_listen(c) })
          end
          
          # Wait for all workers to complete
          @workers.list.each { |t| t.join }

          logger.debug("Reaped listener threads. ")
        
          # Clean up all the connections.
          ActiveRecord::Base.verify_active_connections!
          logger.debug("Cleaned up connection: out!")
        end
      
        # Check if all Worker threads have been started. 
        def started?
          logger.debug("checking if started... list size is #{ worker_threads }")
          Workling::Discovery.discovered.size == worker_threads
        end
        
        # number of worker threads running
        def worker_threads
          @workers.list.size
        end
      
        # Gracefully stop processing
        def stop
          logger.info("stopping threaded poller...")
          sleep 1 until started? # give it a chance to start up before shutting down. 
          logger.info("Giving Listener Threads a chance to shut down. This may take a while... ")
          @workers.list.each { |w| w[:shutdown] = true }
          logger.info("Listener threads were shut down.  ")
        end

        # Listen for one worker class
        def clazz_listen(clazz)
          logger.debug("Listener thread #{clazz.name} started")
           
          # Read thread configuration if available
          if Workling.config.has_key?(:listeners)
            if Workling.config[:listeners].has_key?(clazz.to_s)
              config = Workling.config[:listeners][clazz.to_s].symbolize_keys
              thread_sleep_time = config[:sleep_time] if config.has_key?(:sleep_time)
            end
          end

          hread_sleep_time ||= self.class.sleep_time
                
          # Setup connection to client (one per thread)
          connection = @client_class.new
          connection.connect
          logger.info("** Starting client #{ connection.class } for #{clazz.name} queue")
     
          # Start dispatching those messages
          while (!Thread.current[:shutdown]) do
            begin
            
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
              @mutex.synchronize do 
                ActiveRecord::Base.connection.verify!  # Keep MySQL connection alive
                unless ActiveRecord::Base.connection.active?
                  logger.fatal("Failed - Database not available!")
                end
              end

              # Dispatch and process the messages
              n = dispatch!(connection, clazz)
              logger.debug("Listener thread #{clazz.name} processed #{n.to_s} queue items") if n > 0
              sleep(self.class.sleep_time) unless n > 0
            
              # If there is a memcache error, hang for a bit to give it a chance to fire up again
              # and reset the connection.
              rescue Workling::WorklingConnectionError
                logger.warn("Listener thread #{clazz.name} failed to connect. Resetting connection.")
                sleep(self.class.reset_time)
                connection.reset
            end
          end
        
          logger.debug("Listener thread #{clazz.name} ended")
        end
      
        # Dispatcher for one worker class. Will throw MemCacheError if unable to connect.
        # Returns the number of worker methods called
        def dispatch!(connection, clazz)
          n = 0
          for queue in @routing.queue_names_routing_class(clazz)
            begin
              result = connection.retrieve(queue)
              if result
                n += 1
                handler = @routing[queue]
                method_name = @routing.method_name(queue)
                logger.debug("Calling #{handler.class.to_s}\##{method_name}(#{result.inspect})")
                handler.dispatch_to_worker_method(method_name, result)
              end
            rescue MemCache::MemCacheError => e
              logger.error("FAILED to connect with queue #{ queue }: #{ e } }")
              raise e
            end
          end
        
          return n
        end
      end
    end
  end
end
