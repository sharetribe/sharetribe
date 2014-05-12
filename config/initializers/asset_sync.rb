if defined?(AssetSync)
  AssetSync.configure do |config|
    enabled = APP_CONFIG.aws_access_key_id && APP_CONFIG.aws_secret_access_key && APP_CONFIG.FOG_DIRECTORY && APP_CONFIG.FOG_PROVIDER
    config.run_on_precompile = enabled
    config.enabled = enabled
  end
end