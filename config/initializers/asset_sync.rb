if defined?(AssetSync)
  AssetSync.configure do |config|
    app_config = Maybe(APP_CONFIG)
    aws_access_key_id     = app_config.aws_access_key_id
    aws_secret_access_key = app_config.aws_secret_access_key
    fog_directory         = app_config.FOG_DIRECTORY
    fog_provider          = app_config.FOG_PROVIDER

    enabled = [aws_access_key_id, aws_secret_access_key, fog_directory].all? { |x| x.is_some? }

    puts ""
    puts "AssetSync enabled: #{enabled}"
    puts ""
    puts "Using the following AssetSync configuration:"
    puts "aws_access_key_id:     #{aws_access_key_id.or_else { 'Not available' } }"
    puts "aws_secret_access_key: #{aws_secret_access_key.map { |secret| "*" * secret.length }.or_else { 'Not available' } }"
    puts "fog_directory:         #{fog_directory.or_else { 'Not available' } }"
    puts "fog_provider:          #{fog_provider.or_else { 'Not available' } }"
    puts ""

    config.run_on_precompile = enabled
    config.enabled = enabled

    if enabled
      config.fog_provider          = fog_provider.get
      config.fog_directory         = fog_directory.get
      config.aws_access_key_id     = aws_access_key_id.get
      config.aws_secret_access_key = aws_secret_access_key.get
    end

    config.gzip_compression = app_config.ASSET_SYNC_GZIP_COMPRESSION.or_else(false)
  end
end