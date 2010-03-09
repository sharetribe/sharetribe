require 'workling/remote/runners/client_runner'

#
#  DEPRECATED. Should use ClientRunner instead. 
#
module Workling
  module Remote
    module Runners
      class StarlingRunner < Workling::Remote::Runners::ClientRunner
      end
    end
  end
end