# Using feature flags

Feature flags are a convenient way to toggle certain features per user or per session. Enabled feature flags are fetched in 'ApplicationController', so they are available within controllers and views.

Valid feature flags are defined in `FeatureFlagService::Store`, in `FLAGS` constant.

Feature flags can be accessed by these helper functions:

**`feature_enabled?`**
```ruby
if feature_enabled?(:new_search)
  @search_engine = :zappy
else
  @search_engine = :sphinx
end
```

**`with_feature`**
```ruby
with_feature(:new_logging) do
  new_logger.debug("foo")
end
```

**`feature_flags`**
```ruby
all_features_in_use = feature_flags
```

Feature flags can be toggled in two ways:

1. Query params
If you're logged in as superadmin, you can append `?enable_feature=<your_flag>` to enable the feature for current session

2. Run a command in console
   - Community-specific flag: `FeatureFlagService::API::Api.features.enable(community_id: <community_id>, features: [:<your_flag>])`
   - User-specific flag: `FeatureFlagService::API::Api.features.enable(community_id: <community_id>, person_id: <person_id>, features: [:<your_flag>])`
