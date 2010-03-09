require 'workling/clients/base'

module Workling
  module Clients
    class MemoryQueueClient < Workling::Clients::Base
      
      def initialize
        @subscribers ||= {}
        @queues ||= {}
      end
      
      # collects the worker blocks in a hash
      def subscribe(work_type, &block)
        @subscribers[work_type] = block
      end
      
      # immediately invokes the required worker block
      def request(work_type, arguments)
        if subscription = @subscribers[work_type]
          subscription.call(arguments)
        else
          @queues[work_type] ||= []
          @queues[work_type] << arguments
        end
      end
      
      def retrieve(work_type)
        queue = @queues[work_type]
        queue.pop if queue
      end
      
      def connect; true; end
      def close; true; end
    end
  end
end