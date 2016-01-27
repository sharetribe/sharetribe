# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

# Will use the secert found in the file if exists. Otherwise generate new and store.

if APP_CONFIG.secret_key_base
  Rails.application.config.secret_key_base = APP_CONFIG.secret_key_base
else
  warning = [
    "'secret_key_base' is not set.",
    "Run SecureRandom.hex(64) in rails console or irb to generate a new key.",
    "Add 'secret_key_base' key to config.yml or to environment variables.",
  ].join(" ")

  Rails.logger.warn(warning)
end

# TODO Deprecated. Remove this code STARTS.
secret_file = File.join(Rails.root.to_s, "config/session_secret")

secret =
  if File.exist?(secret_file)
    File.read(secret_file)
  elsif APP_CONFIG.session_secret
    APP_CONFIG.session_secret
  end

Rails.application.config.secret_token = secret
# Remove this code ENDS
