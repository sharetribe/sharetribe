#
#  Base class for Workling Runners.
#
#  Runners must subclass this and implement the method 
#
#     Workling::Remote::Runners::Base#run(clazz, method, options = {})
#
#  which is responsible for pushing the requested job into the background. Depending
#  on the Runner, this may require other code to dequeue the job. The actual
#  invocation of the runner should be done like this: 
#
#      Workling.find(clazz, method).dispatch_to_worker_method(method, options)
#
#  This ensures for consistent logging and handling of propagated exceptions. You can
#  also call the convenience method 
#       
#      Workling::Remote::Runners::Base#dispatch!(clazz, method, options)
#
#  which invokes this for you. 
#
module Workling
  module Remote
    module Runners
      class Base
        
        # runner uses this to connect to a job broker
        cattr_accessor :client
        
        # default logger defined in Workling::Base.logger
        def logger
          Workling::Base.logger
        end

        # find the worker instance and invoke it. Invoking the worker method like this ensures for 
        # consistent logging and handling of propagated exceptions. 
        def dispatch!(clazz, method, options)
          Workling.find(clazz, method).dispatch_to_worker_method(method, options)
        end
      end
    end
  end
end
