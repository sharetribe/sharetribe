require 'workling/routing/base'

#
#  Holds a hash of routes. Each Worker method has a corresponding hash entry after building. 
#
module Workling
  module Routing
    class ClassAndMethodRouting < Base
          
      # initializes and builds routing hash. 
      def initialize
        super

        build
      end
      
      # returns the worker method name, given the routing string. 
      def method_name(queue)
        queue.split("__").last
      end
      
      # returns the routing string, given a class and method. delegating. 
      def queue_for(clazz, method)
        ClassAndMethodRouting.queue_for(clazz, method)
      end
              
      # returns the routing string, given a class and method.
      def self.queue_for(clazz, method)
        "#{ clazz.to_s.tableize }/#{ method }".split("/").join("__") # Don't split with : because it messes up memcache stats
      end
      
      # returns all routed
      def queue_names
        self.keys
      end
      
      # dare you to remove this! go on! 
      def queue_names_routing_class(clazz)
        self.select { |x, y|  y.is_a?(clazz) }.map { |x, y| x }
      end
      
      private
        def build
          Workling::Discovery.discovered.each do |clazz|
            methods = clazz.instance_methods(false)
            methods.each do |method|
              next if method == 'create'  # Skip the create method
              queue =  queue_for(clazz, method)
              self[queue] = clazz.new
            end   
          end     
        end       
    end
  end
end