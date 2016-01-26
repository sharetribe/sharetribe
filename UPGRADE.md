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

## Upgrade from 5.x to [Unreleased]

After updating, you are not able to downgrade to Rails 3 (version 4.6.0). Do not upgrade until you are sure that you don't need to roll back to Rails 3.

## Upgrade from 4.6.0 to 5.0.0

After you have deployed the new version you need to clear Rails cache by running to following command in your production application Rails console:

```
Rails.cache.clear
```

If something goes wrong, you can safely roll back this version back to 4.6.0. You don't need to roll back the database migrations. You may need to empty the cache again after the rollback.
