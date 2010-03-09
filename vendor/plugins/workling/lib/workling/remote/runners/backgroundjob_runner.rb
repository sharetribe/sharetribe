require 'workling/remote/runners/base'

#
#  Use Ara Howards BackgroundJob to run the work. BackgroundJob loads Rails once per requested Job. 
#  It persists over the database, and there is no requirement for separate processes to be started. 
#  Since rails has to load before each request, it takes a moment for the job to run. 
#
module Workling
  module Remote
    module Runners
      class BackgroundjobRunner < Workling::Remote::Runners::Base
        cattr_accessor :routing
        
        def initialize
          BackgroundjobRunner.routing = 
            Workling::Routing::ClassAndMethodRouting.new
        end
        
        #  passes the job to bj by serializing the options to xml and passing them to
        #  ./script/bj_invoker.rb, which in turn routes the deserialized args to the
        #  appropriate worker. 
        def run(clazz, method, options = {})
          stdin = @@routing.queue_for(clazz, method) + 
                  " " + 
                  options.to_xml(:indent => 0, :skip_instruct => true)
                  
          Bj.submit "./script/runner ./script/bj_invoker.rb", 
            :stdin => stdin
          
          return nil # that means nothing!
        end
      end
    end
  end
end