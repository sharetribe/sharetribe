require 'workling/remote/runners/base'

#
#  Run the job over the spawn plugin. Refer to the README for instructions on 
#  installing Spawn. 
#
#  Spawn forks the entire process once for each job. This means that the job starts 
#  with a very low latency, but takes up more memory for each job. 
# 
#  It's also possible to configure Spawn to start a Thread for each job. Do this
#  by setting
#
#      Workling::Remote::Runners::SpawnRunner.options = { :method => :thread }
#
#  Have a look at the Spawn README to find out more about the characteristics of this. 
#
module Workling
  module Remote
    module Runners
      class SpawnRunner < Workling::Remote::Runners::Base
        cattr_accessor :options
        
        # use thread for development and test modes. easier to hunt down exceptions that way. 
        @@options = { :method => (RAILS_ENV == "test" || RAILS_ENV == "development" ? :thread : :fork) }
        include Spawn if Workling.spawn_installed?
        
        # dispatches to Spawn, using the :fork option. 
        def run(clazz, method, options = {})
          spawn(SpawnRunner.options) do # exceptions are trapped in here. 
            dispatch!(clazz, method, options)
          end
          
          return nil # that means nothing!
        end
      end
    end
  end
end