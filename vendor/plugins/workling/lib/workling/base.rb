#
#  All worker classes must inherit from this class, and be saved in app/workers. 
# 
#  The Worker lifecycle: 
#    The Worker is loaded once, at which point the instance method 'create' is called. 
#
#  Invoking Workers: 
#    Calling async_my_method on the worker class will trigger background work.
#    This means that the loaded Worker instance will receive a call to the method
#    my_method(:uid => "thisjobsuid2348732947923"). 
#
#    The Worker method must have a single hash argument. Note that the job :uid will
#    be merged into the hash. 
#
module Workling
  class Base
    cattr_accessor :logger
    @@logger ||= ::RAILS_DEFAULT_LOGGER
    
    def self.inherited(subclass)
      Workling::Discovery.discovered << subclass
    end
    
    def initialize
      super
      
      create
    end

    # Put worker initialization code in here. This is good for restarting jobs that
    # were interrupted.
    def create
    end
    
    # takes care of suppressing remote errors but raising Workling::WorklingNotFoundError
    # where appropriate. swallow workling exceptions so that everything behaves like remote code.
    # otherwise StarlingRunner and SpawnRunner would behave too differently to NotRemoteRunner.
    def dispatch_to_worker_method(method, options)
      begin
        self.send(method, options)
      rescue Exception => e
        raise e if e.kind_of?(Workling::WorklingError)
        logger.error "WORKLING ERROR: runner could not invoke #{ self.class }:#{ method } with #{ options.inspect }. error was: #{ e.inspect }\n #{ e.backtrace.join("\n") }"

        # reraise after logging. the exception really can't go anywhere in many cases. (spawn traps the exception)
        raise e if Workling.raise_exceptions?
      end
    end    
  
    # thanks to blaine cook for this suggestion.
    def self.method_missing(method, *args, &block)
      if method.to_s =~ /^asynch?_(.*)/
        Workling::Remote.run(self.to_s.dasherize, $1, *args)
      else
        super
      end
    end
  end
end