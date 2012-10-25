require 'openssl'
require 'digest/sha2'

module Devise
  module Encryptable
    module Encryptors
      class Asi < Base
      
        def self.digest(password, stretches, salt, pepper)
          str = [password, salt].flatten.compact.join
          Digest::SHA256.hexdigest(str)
        end
      end
    end
  end
end