require 'workling/base'

module Analytics
  class Invites < ::Workling::Base
    
    def sent(*args)
      logger.info("nice")
    end
  end
end