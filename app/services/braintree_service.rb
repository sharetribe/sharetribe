#
# This class makes Braintree calls thread-safe even though we're using
# different configurations per Braintree call
#
class BraintreeService
  class << self
    mutex = Mutex.new

    # Give `community` and set Braintree configurations
    def configure_for(community)
      # TODO
    end

    # Reset Braintree configurations
    def reset_configurations()
      # TODO
    end

    def do_stuff(community)
      
      mutex.synchronize {
        configure_for(community)

        # Now do stuff

        reset_configurations()
      }

    end
  end
end