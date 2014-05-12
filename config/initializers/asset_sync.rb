if defined?(AssetSync)
  AssetSync.configure do |config|
    app_config = Maybe(APP_CONFIG)
    aws_access_key_id     = app_config.aws_access_key_id.or_else(false)
    aws_secret_access_key = app_config.aws_secret_access_key.or_else(false)
    fog_directory         = app_config.FOG_DIRECTORY.or_else(false)
    fog_provider          = app_config.FOG_PROVIDER.or_else(false)

    enabled = !!(aws_access_key_id && aws_secret_access_key && fog_provider && fog_directory)

    puts "AssetSync enabled: #{enabled}"
    config.run_on_precompile = enabled
    config.enabled = enabled

    if enabled
      config.fog_provider          = fog_provider
      config.fog_directory         = fog_directory
      config.aws_access_key_id     = aws_access_key_id
      config.aws_secret_access_key = aws_secret_access_key
    end

    config.gzip_compression = app_config.ASSET_SYNC_GZIP_COMPRESSION.or_else(false)
  end
end