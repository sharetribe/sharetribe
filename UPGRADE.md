# Upgrade

Upgrade notes will be documented in this file.

## General update instructions

First things first, take a backup of your database before updating.

To fetch the latest code, run:

```bash
git fetch --tags
git checkout latest
```

After updating the code, run the following commands to update gem set, npm packages and database structure:

```bash
bundle install
npm install
RAILS_ENV=production rake db:migrate

# If you're running on local instance (localhost), you also need to precompile assets:
rake assets:precompile
```

### Maintenance mode

Some version updates may require you to put your application on maintenance mode.

To show a warning message to your application users you can set the time of the next maintenance mode to `next_maintenance_at` environment variable. This will show a warning to all users 15 minutes before the maintenance.

To enable the warning in Heroku:

```bash
heroku config:set next_maintenance_at="2016-04-29 17:15:00 +0000" --app=<your app name>
```

See instructions how to set application in [maintenance mode in Heroku](https://devcenter.heroku.com/articles/maintenance-mode).

## Unreleased

## Upgrade from 7.3.1 to 7.4.0

Nothing special. See the [#general-update-instructions].

## Upgrade from 7.3.0 to 7.3.1

Nothing special. See the [#general-update-instructions].

## Upgrade from 7.2.0 to 7.3.0

Nothing special. See the [#general-update-instructions].

## Upgrade from 7.1.0 to 7.2.0

Nothing special. See the [#general-update-instructions].

## Upgrade from 7.0.0 to 7.1.0

Ruby version is updated from 2.3.1 to 2.3.4. The update contains fixes for several security vulnerabilities.

Using [RVM](https://rvm.io/), you can upgrade your local Ruby version like this:

```
rvm install ruby-2.3.4
rvm use ruby-2.3.4
gem install bundler
bundle install
```

## Upgrade from 6.4.0 to 7.0.0

Make sure you have node 7.8 installed.

Then follow the [#general-update-instructions].

If foreman causes trouble with an error message:

```
'method_missing': undefined method 'this'
```

it's an issue with rubygems. This issue can be solved by updating rubygems with:

```bash
gem update --system
```


## Upgrade from 6.3.0 to 6.4.0

Nothing special. See the [#general-update-instructions].

## Upgrade from 6.2.0 to 6.3.0

### Migration from database session store to cookie-based session store

This release migrates from database session store to cookie-based session store. The migration is done seamlessly without users being logged out.

Make sure that you are using a cache store that can share cache between processes (such as FileStore, MemCacheStore or Redis) if you are running multiple server processes. The new session implementation caches user session data and if the cache is not shared between all server processes they will get out of sync and actions such as logout will only log out the user from one process but not from all processes. See this [Rails Guides](http://guides.rubyonrails.org/caching_with_rails.html#cache-stores) article to read more about Cache Stores in Rails.

Add a new scheduled task to clean up expired tokens. Run it once per day:

```
bundle exec rails runner ActiveSessionsHelper.cleanup
```

To read more, see [Scheduled tasks](docs/scheduled_tasks.md).

## Upgrade from 6.1.0 to 6.2.0

NPM packages are updated, run `npm install` to get the latest packages.

## Upgrade from 6.0.0 to 6.1.0

In this release we are introducing layout changes that require new image styles. Therefore, a migration is added to reprocess all images from open listings into new styles. This does not require any precautions, but if your marketplace has a lot of open listings the time required for image reprocessing can be reduced by increasing the number of workers until all `CreateSquareImagesJob` jobs have been processed.

This release updates Node.js to the latest LTS (long term support) version 6.9. You should update your local Node.js to the same version and run `npm install` to update the NPM packages. There is now a strict enforcement for the Node.js version, and building the frontend bundles fail when using an unsupported version of Node.js.

Alongside the updated NPM packages, also the `react_on_rails` gem is updated to match the NPM package version, and requires running `bundle install` to install the latest version.

## Upgrade from 5.12.0 to 6.0.0

Release 6.0.0 drops official support for MySQL server version 5.6. Please upgrade to 5.7 when upgrading Sharetribe. See the upgrade notes from release 5.12.0 below for more information.

## Upgrade from 5.11.0 to 5.12.0

**IMPORTANT:** This release deprecates use of MySQL server version 5.6.x. Please, consider upgrading to MySQL 5.7. Support for MySQL 5.6 will be dropped with the next release of Sharetribe. From this point onward, versions other than 5.7 might work, but are not guaranteed to work with Sharetribe. Make sure to back up your database before upgrading MySQL server. For general upgrade instructions, see [the official MySQL upgrade instructions](http://dev.mysql.com/doc/refman/5.7/en/upgrading.html).

If you are using S3 and are using an AWS region other than `us-east-1`, you need to update your `config.yml` file and set the `s3_region` configuration option to the AWS region you are using. As with all configuration options, you can also pass it as an environment variable.

## Upgrade from 5.10.0 to 5.11.0

This version is the second phase of removing support for Braintree payments. Old payment data for Braintree transactions will be removed in the migrations. If you want to save this data, you should take a backup before updating.

After the upgrade to 5.10.0 no new transactions could be started with Braintree anymore, and before upgrading to this version you should make sure that there are no ongoing Braintree transactions. You can check the status of each transaction in the transaction view in the admin panel. All transaction statuses should be either Conversation, Confirmed, Canceled, or Rejected.

## Upgrade from 5.9.0 to 5.10.0

This version starts the two step process of disabling Braintree payments. In the first phase new payments are disabled with Braintree. The main purpose of this version is to ensure that there will be no new Braintree transactions. Existing transactions can be completed still after this update.

This version changes existing transaction processes, so taking a backup before upgrading is recommended.

Reasoning behind removing Braintree support can be seen in the [Community forum post](https://www.sharetribe.com/community/t/braintree-integration-will-be-removed-from-sharetribe/225).

## Upgrade from 5.8.0 to 5.9.0

This release removes the need to run CSS compilation workers. There is no CSS compilation per marketplace anymore. The `Procfile` has been updated, so if you run on Heroku, the `css_compile` worker should disappear after deployment.

NPM packages have been updated, run `npm install` to ensure you have the correct versions installed.

## Upgrade from 5.7.1 to 5.8.0

This release doesn't require any extra actions.

## Upgrade from 5.7.0 to 5.7.1

This is a bug fix release and does not require any extra actions.

## Upgrade from 5.6.0 to 5.7.0

### Separate CSS compilation workers

This release adds a new Delayed Job queue "css_compile". All CSS compilations during the deployment are added to this queue. However, CSS compilations triggered from the admin UI do NOT go into this queue, instead they are added to the "default" queue.

A new worker is added to the Procfile to work for the new queue. If you're hosting in Heroku, you will see a new worker there.

This change doesn't require any changes, if you are compiling the stylesheets synchronously using the `rake sharetribe:generate_customization_stylesheets_immediately` command during the deployment. However, if you are compiling the stylesheets asynchronously using the `rake sharetribe:generate_customization_stylesheets` command, then you need to make sure that you have at least one worker working for the "css_compile" queue.

### Ruby version 2.2.4 -> 2.3.1

Ruby version is updated from 2.2.4 to 2.3.1. The update should bring performance improvements.

Using [RVM](https://rvm.io/), you can upgrade your local Ruby version like this:

```
rvm install ruby-2.3.1
rvm use ruby-2.3.1
gem install bundler
bundle install
```

### React on Rails build environment

React on Rails build environment is added in this release. This means that build environment needs to have `node` set up. With Heroku this can be set with `heroku buildpacks:add --index 1 heroku/nodejs`. For other environments - see [npm instructions](https://docs.npmjs.com/getting-started/installing-node), [nvm](https://github.com/creationix/nvm), or [n](https://github.com/tj/n). In addition, production environments should have `NODE_ENV=production` set.

After bundle install, you should also install `npm` packages:

```bash
npm install
```

### User account migrations

This doesn't apply to OS version as it doesn't officially support running multiple marketplaces in one Sharetribe instance.

This release removes the ability for one user to belong to multiple marketplaces. From now on one user belongs to one and only one marketplace.

Because of that, this release contains quite a few migrations which will duplicate existing user accounts, if they belong to multiple communities. For example, if one user belongs to three communities, two new users will be created so that each user belongs to only one community.

The migrations are not safe to run while the application is running, so we recommend you to put the application on [maintenance mode](#maintenance-mode) while running the migrations. Also, as always, remember to take database backup before migrating.

### Session separation

This release separates cookies by subdomain so that foo.sharetribe.com and bar.sharetribe.com have now separate session cookies. In order to migrate old sessions as smoothly as possible a new configuration option `cookie_session_key` has been added to `config.defaults.yml`. If you want to use custom session key, this variable must be set as an environment variable before deployment. Otherwise, session cookies might overlap and cause issues with log in.

## Upgrade from 5.5.0 to 5.6.0

Ruby version is updated from 2.1.8 to 2.2.4. The update should reduce memory usage and improve performance.

Using [RVM](https://rvm.io/), you can upgrade your local Ruby version like this:

```
rvm install ruby-2.2.4
rvm use ruby-2.2.4
gem install bundler
bundle install
```

## Upgrade from 5.4.0 to 5.5.0

This release removes the support for legacy hashing algorithm that was used with the legacy "ASI" service.

If `use_asi_encryptor` was configured to `false` (default) then you can safely upgrade and roll back this release.

However, if `use_asi_encryptor` was configured to `true` then you can not roll back this released without losing user authentication data. If you need to roll back, users need to request new password by clicking the "Forgot password link".

## Upgrade from 5.3.0 to 5.4.0

Ruby version is updated from 2.1.2 to 2.1.8. The update contains security and bug fixes.

Using [RVM](https://rvm.io/), you can upgrade your local Ruby version like this:
```
rvm install ruby-2.1.8
rvm use ruby-2.1.8
gem install bundler
bundle install
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
