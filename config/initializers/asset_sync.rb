require "asset_sync"

# Disable AssetSync by default if no Fog Provider is defined
unless ENV['FOG_PROVIDER']
  AssetSync.config.enabled = false
end

