# Upgrade

Upgrade notes will be documented in this file.

## General update instructions

When updating, always run the following commands to update gem set, database structure and recompile custom stylesheet:

```bash
bundle install
RAILS_ENV=production rake db:migrate
RAILS_ENV=production rake sharetribe:generate_customization_stylesheets_immediately

# if running on local instance (localhost), you need to precompile assets using once update is done:
rake assets:precompile
```

## Upgrade from 5.2.x to 5.3.0

This version contains some changes to the caching logic. The Rails cache needs to be cleared before upgrading.

Upgrade path:

1. Upgrade to version 5.2.2
2. Clear Rails cache (run `Rails.cache.clear`)
3. Upgrade to version 5.3.0

## Upgrade from 5.0.x or 5.1.x to 5.2.0

* After updating, you are not able to downgrade to Rails 3 (version 4.6.0). Do not upgrade until you are sure that you don't need to roll back to Rails 3.

* You need to set `secret_key_base` to environment variables or to `config.yml` for `production` environment. Default values for `development` and `test` environments are provided.

  Run `SecureRandom.hex(64)` in rails console or irb to generate a new key.

* This version changes the way how password reset tokens are being stored to the database. Due to this, tokens that are created with the earlier versions do not work anymore.

  For seamless migration, set the environment variable `devise_allow_insecure_token_lookup` to `true`. After you are sure you have migrated all the reset tokens to the new format, you can remove the environment variable.

## Upgrade from 4.6.0 to 5.0.0

After you have deployed the new version you need to clear Rails cache by running to following command in your production application Rails console:

```
Rails.cache.clear
```

If something goes wrong, you can safely roll back this version back to 4.6.0. You don't need to roll back the database migrations. You may need to empty the cache again after the rollback.
