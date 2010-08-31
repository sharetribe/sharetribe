require 'recaptcha/client_helper'
require 'recaptcha/verify'

module Recaptcha
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 2
    TINY  = 2
    PATCH = 1

    STRING = [MAJOR, MINOR, TINY, PATCH].join('.')
  end

  
  RECAPTCHA_API_SERVER        = 'http://api.recaptcha.net';
  RECAPTCHA_API_SECURE_SERVER = 'https://api-secure.recaptcha.net';
  RECAPTCHA_VERIFY_SERVER     = 'api-verify.recaptcha.net';

  SKIP_VERIFY_ENV = ['test', 'cucumber']

  class RecaptchaError < StandardError
  end
end