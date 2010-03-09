#
#  Base Class for Routing. Routing takes the worker method TestWorker#something, 
#  and serializes the signature in some way. 
#
module Workling
  module Routing
    class Base < Hash
      def method_name
        raise Exception.new("method_name not implemented.")
      end
    end
  end
end