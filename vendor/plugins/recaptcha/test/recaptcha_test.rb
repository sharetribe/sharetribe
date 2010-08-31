require 'test/unit'
require 'cgi'
require File.dirname(__FILE__) + '/../lib/recaptcha'

class RecaptchaClientHelperTest < Test::Unit::TestCase
  include Recaptcha
  include Recaptcha::ClientHelper
  include Recaptcha::Verify

  attr_accessor :session

  def setup
    @session = {}
    ENV['RECAPTCHA_PUBLIC_KEY']  = '0000000000000000000000000000000000000000'
    ENV['RECAPTCHA_PRIVATE_KEY'] = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  end
    
  def test_recaptcha_tags
    # Might as well match something...
    assert_match /http:\/\/api.recaptcha.net/, recaptcha_tags 
  end
  
  def test_recaptcha_tags_with_ssl
    assert_match /https:\/\/api-secure.recaptcha.net/, recaptcha_tags(:ssl => true)
  end

  def test_recaptcha_tags_without_noscript
    assert_no_match /noscript/, recaptcha_tags(:noscript => false)
  end
  
  def test_should_raise_exception_without_public_key
    assert_raise RecaptchaError do
      ENV['RECAPTCHA_PUBLIC_KEY'] = nil
      recaptcha_tags
    end
  end
end
