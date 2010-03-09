require 'workling/clients/base'

module Workling
  module Clients
    class MemcacheQueueClient < Workling::Clients::Base
      def raise_unless_connected!; end
    end
  end
end