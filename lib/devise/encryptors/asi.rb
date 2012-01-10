require 'openssl'
require 'digest/sha2'

module Devise
  module Encryptors
    class Asi < Base
     # KEY = APP_CONFIG.crypto_helper_key
      
      def self.digest(password, stretches, salt, pepper)
        str = [password, salt].flatten.compact.join
        Digest::SHA256.hexdigest(str)
      end
    end
  end
end