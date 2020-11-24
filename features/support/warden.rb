# gives us the login_as(@user) method when request object is not present
include Warden::Test::Helpers # rubocop:disable Style/MixinUsage
Warden.test_mode!

After do |scenario|
  Warden.test_reset!
end
