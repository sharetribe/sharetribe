# Sharetribe

[![CircleCI](https://circleci.com/gh/sharetribe/sharetribe/tree/master.svg?style=svg)](https://circleci.com/gh/sharetribe/sharetribe/tree/master) [![Dependency Status](https://gemnasium.com/sharetribe/sharetribe.png)](https://gemnasium.com/sharetribe/sharetribe) [![Code Climate](https://codeclimate.com/github/sharetribe/sharetribe.png)](https://codeclimate.com/github/sharetribe/sharetribe)

Sharetribe is an open source platform to create your own peer-to-peer marketplace.

Would you like to set up your marketplace in one minute without touching code? [Head to Sharetribe.com](https://www.sharetribe.com).

### Contents

- [Technology stack](#technology-stack)
- [Installation](#installation)
- [Payments](#payments)
- [Versioning](#versioning)
- [Changes](#changes)
- [Upgrade](#upgrade)
- [Contribute](#contribute)
- [Release](#release)
- [Translation](#translation)
- [Bug tracker](#bug-tracker)
- [Documentation](#documentation)
- [Community forum](#community-forum)
- [License](#mit-license)

## Technology stack

- Ruby 2.3
- Ruby on Rails 5.1.1
- MySQL  5.7
- React + jQuery
- Node.js 7.8 (for compiling JavaScript assets)
- "what you see is what you get" Editor [Mercury](http://jejacks0n.github.io/mercury/)
- Deploy: Custom Script (not using Mina or Cap3)
- Server: Heroku
- Image hosting: Amazon S3
- Background job: [delayed_job](https://github.com/collectiveidea/delayed_job)
- Gems:
    -  [devise](https://github.com/plataformatec/devise) | Authentication
    -  [omniauth-facebook](https://github.com/mkdynamic/omniauth-facebook) | Third party login: Facebook
    -  [haml](https://github.com/haml/haml) and ERB | HTML teamplating
    -  [mysql2](https://github.com/brianmario/mysql2) | MySQL library for Ruby
    -  [paperclip](https://github.com/thoughtbot/paperclip) | Image upload management
    -  [passenger](https://github.com/phusion/passenger) | Web application server
    -  [react_on_rails](https://github.com/shakacode/react_on_rails) | Integration of React + Webpack + Rails
    -  factory_girl, capybara, rspec-rails, cucumber-rails, selenium-webdriver | Testing

## Installation

### Requirements

Before you get started, the following needs to be installed:
  * **Ruby**. Version 2.3.4 is currently used and we don't guarantee everything works with other versions. If you need multiple versions of Ruby, [RVM](https://rvm.io//) or [rbenv](https://github.com/rbenv/rbenv) is recommended.
  * [**RubyGems**](http://rubygems.org/)
  * **Bundler**: `gem install bundler`
  * **Node**. Version 7.8 is currently used and we don't guarantee everything works with other versions. If you need multiple versions of Node, consider using [n](https://github.com/tj/n), [nvm](https://github.com/creationix/nvm), or [nenv](https://github.com/ryuone/nenv).
  * [**Git**](http://help.github.com/git-installation-redirect)
  * **A database**. Only MySQL 5.7 has been tested, so we give no guarantees that other databases (e.g. PostgreSQL) work. You can install MySQL Community Server two ways:
    1. If you are on a Mac, use homebrew: `brew install mysql` (*highly* recommended). Also consider installing the [MySQL Preference Pane](https://dev.mysql.com/doc/refman/5.1/en/osx-installation-prefpane.html) to control MySQL startup and shutdown. It is packaged with the MySQL downloadable installer, but can be easily installed as a stand-alone.
    2. Download a [MySQL installer from here](http://dev.mysql.com/downloads/mysql/)
  * [**Sphinx**](http://pat.github.com/ts/en/installing_sphinx.html). Version 2.1.4 has been used successfully, but newer versions should work as well. Make sure to enable MySQL support. If you're using OS X and have Homebrew installed, install it with `brew install sphinx --with-mysql`
  * [**Imagemagick**](http://www.imagemagick.org). If you're using OS X and have Homebrew installed, install it with `brew install imagemagick`

### Setting up the development environment

1.  Get the code. Clone this git repository and check out the latest release:

    ```bash
    git clone git://github.com/sharetribe/sharetribe.git
    cd sharetribe
    git checkout latest
    ```

1.  Install the required gems by running the following command in the project root directory:

    ```bash
    bundle install
    ```

    **Note:** [`libv8` might fail to build with Clang 7.3](https://github.com/cowboyd/libv8/pull/207), in that case you can try installing V8 manually:

    ```bash
    brew tap homebrew/versions
    brew install v8-315

    gem install libv8 -v '3.16.14.13' -- --with-system-v8
    gem install therubyracer -- --with-v8-dir=/usr/local/opt/v8-315

    bundle install
    ```

1.  Install node modules:

    ```bash
    npm install
    ```

1.  Create a `database.yml` file by copying the example database configuration:

    ```bash
    cp config/database.example.yml config/database.yml
    ```

1.  Add your database configuration details to `config/database.yml`. You will probably only need to fill in the password for the database(s).

1.  Create a `config.yml` file by copying the example configuration file:

    ```bash
    cp config/config.example.yml config/config.yml
    ```

1.  Create and initialize the database:

    ```bash
    bundle exec rake db:create db:structure:load
    ```

1.  Run Sphinx index:

    ```bash
    bundle exec rake ts:index
    ```

    **Note:** If your MySQL server is configured for SSL, update the `config/thinking_sphinx.yml` file and uncomment the `mysql_ssl_ca` lines. Configure correct SSL certificate chain for connection to your database over SSL.

1.  Start the Sphinx daemon:

    ```bash
    bundle exec rake ts:start
    ```

1.  Start the development server:

    ```bash
    foreman start -f Procfile.static
    ```

1.  Invoke the delayed job worker in a new console (open the project root folder):

    ```bash
    bundle exec rake jobs:work
    ```


Congratulations! Sharetribe should now be up and running for development purposes. Open a browser and go to the server URL (e.g. http://lvh.me:3000). Fill in the form to create a new marketplace and admin user. You should be now able to access your marketplace and modify it from the admin area.

### Mailcatcher

Use [Mailcatcher](http://mailcatcher.me) to receive sent emails locally:

1.  Install Mailcatcher:

    ```bash
    gem install mailcatcher
    ```

1.  Start it:

    ```bash
    mailcatcher
    ```

1.  Add the following lines to `config/config.yml`:

    ```yml
    development:
      mail_delivery_method: smtp
      smtp_email_address: "localhost"
      smtp_email_port: 1025
    ```

1.  Open `http://localhost:1080` in your browser

### Database migrations

To update your local database schema to the newest version, run database migrations with:

  ```bash
  bundle exec rake db:migrate
  ```

### Running tests

Tests are handled by [RSpec](http://rspec.info/) for unit tests and [Cucumber](https://cucumber.io/) for acceptance tests.

Remember to follow *all* the steps listed in the [Setting up the development environment](#setting-up-the-development-environment) paragraph before running tests because some tests depend on webpack assets.

1.  Navigate to the root directory of the sharetribe project

1.  Initialize your test database:

    ```bash
    bundle exec rake test:prepare
    ```

    This needs to be rerun whenever you make changes to your database schema.

1.  If Zeus isn't running, start it:

    ```bash
    zeus start
    ```

1.  To run unit tests, open another terminal and run:

    ```bash
    zeus rspec spec
    ```

1.  To run acceptance tests, open another terminal and run:

    ```bash
    zeus cucumber
    ```

    Note that running acceptance tests is slow and may take a long time to complete.

To automatically run unit tests when code is changed, start [Guard](https://github.com/guard/guard):

  ```bash
  bundle exec guard
  ```

### Working with React, Webpack and Foreman

Some components are created with React (see [documentation](https://github.com/sharetribe/sharetribe/blob/master/client/README.md)) and they need to be built with Webpack. We have [Foreman](http://theforeman.org/) Procfiles that can be used to run both Rails and Webpack:

1.  React component static build

    ```bash
    foreman start -f Procfile.static
    ```

1.  React component & hot loading styleguide (http://localhost:9001/)

    ```bash
    foreman start -f Procfile.hot
    ```

1.  If you need to debug the Rails parts of Sharetribe with [Pry](https://github.com/pry/pry), it's not possible with Foreman due to a [known compatibility issue](https://github.com/ddollar/foreman/pull/536). In this case we recommend running Rails with old-fashioned `rails server` and React builds with Foreman in a separate terminal. That way your `binding.pry` calls open nicely in the same window with the Rails process.

1.  React component static build, React client only

    ```bash
    foreman start -f Procfile.client-static
    ```

1.  React component & hot loading styleguide (http://localhost:9001/), React client only

    ```bash
    foreman start -f Procfile.client-hot
    ```

### Setting up Sharetribe for production

Before starting these steps, perform [steps 1-5 from above](#setting-up-the-development-environment).

1.  Set `secret_key_base`

    Generate secret key

    ```bash
    rake secret
    ```

    Add the following lines to `config/config.yml`:

    ```yml
    production:
      secret_key_base: # add here the generated key
    ```

    (You can also set the `secret_key_base` environment variable, if you don't want to store the secret key in a file)

1.  Create the database:

    ```bash
    RAILS_ENV=production bundle exec rake db:create
    ```

1.  Initialize your database:

    ```bash
    RAILS_ENV=production bundle exec rake db:structure:load
    ```

1.  Run Sphinx index:

    ```bash
    RAILS_ENV=production bundle exec rake ts:index
    ```

1.  Start the Sphinx daemon:

    ```bash
    RAILS_ENV=production bundle exec rake ts:start
    ```

1.  Precompile the assets:

    ```bash
    RAILS_ENV=production NODE_ENV=production bundle exec rake assets:precompile
    ```

1.  Invoke the delayed job worker:

    ```bash
    RAILS_ENV=production bundle exec rake jobs:work
    ```

1.  In a new console, open the project root folder and start the server:

    ```bash
    bundle exec rails server -e production
    ```


The built-in WEBrick server (which was started in the last step above) should not be used in production due to performance reasons. A dedicated HTTP server such as [unicorn](http://unicorn.bogomips.org/) is recommended.

It is not recommended to serve static assets from a Rails server in production. Instead, you should use a CDN (Content Delivery Network) service, such as [Amazon CloudFront](https://aws.amazon.com/cloudfront/). To serve the assets from the CDN service, you need to change the `asset_host` configuration in the the `config/config.yml` file to point your CDN distribution.

You need to configure a couple scheduled tasks in order to properly run your marketplace in production. See the [Scheduled tasks](docs/scheduled_tasks.md) documentation.

**For production use we recommend you to upgrade only when new version is released and not to follow the master branch.**

#### Setting your domain

1. In your database, change the value of the `domain` column in the `communities` table to match the hostname of your domain. For example, if the URL for your marketplace is http://mymarketplace.myhosting.com, then the domain is `mymarketplace.myhosting.com`.

1. Change the value of the `use_domain` column to `true` (or `1`) in the `communities` table.


#### Setting up S3

If you want to use S3 to host your images, you need to do a bit more configuration.

1. Create a IAM role which has full S3 access.  Save the AWS access and secret keys.

1. In the S3 console, create two buckets, one for upload and one for permanent storage.  For example `your-sharetribe-images` and `your-sharetribe-images-tmp`.

1. Set the upload bucket (`your-sharetribe-images-tmp`) to have an expiration (for example, of 14 days) using [lifecycle management](https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lifecycle-mgmt.html)

1. [Enable CORS on the upload bucket](https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html).

1. Set the following configuration in your sharetribe `config.yml`: `s3_bucket_name: "your-sharetribe-images"` `s3_upload_bucket_name:  "your-sharetribe-images-tmp"`

1. Add your AWS keys to the sharetribe app.  The best way to do that is via environment variables, rather than checking them into your `config.yml`.  Set the `aws_access_key_id` and `aws_secret_access_key` environment variables to the values for the IAM user.

1. (Optional) When you enable S3, uploaded images are linked directly to the S3 bucket. If you want to serve these assets through CDN, you can set the `user_asset_host` configuration option in addition to `asset_host` in `config/config.yml`.


Here's a sample CORS configuration that allows anyone to post to your bucket.  Note that you may want to lock down the origin host more tightly, depending on your needs.

```
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
        <AllowedOrigin>*</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
        <AllowedMethod>POST</AllowedMethod>
        <MaxAgeSeconds>3000</MaxAgeSeconds>
        <AllowedHeader>*</AllowedHeader>
    </CORSRule>
</CORSConfiguration>
```

##### Troubleshooting S3 Setup

* if you are having trouble uploading, look at the request using browser devtools and see what error statuses and messages are being sent.
* double check that your AWS keys are being correctly set.
* if you can upload images successfully, but the images aren't processed, make sure that the delayed-job worker is running.

### Advanced settings

Default configuration settings are stored in `config/config.default.yml`. If you need to change these, use the `config/config.yml` file to override the defaults. You can also set configuration values to environment variables.

React components can be created using hot module replacement HMR technique in Styleguide (http://localhost:9001/) path in local development environment. Webpack is used to bundle React components for deployments and hot loading. Related webpack configs can be found from folder sharetribe/client/

### Unofficial installation instructions

Use these instructions to set up and deploy Sharetribe for production in different environments. They have been put together by the developer community, and are not officially maintained by the Sharetribe core team. The instructions might be somewhat out of date.

If you have installation instructions that you would like to share, don't hesitate to share them at the [Sharetribe community forum](https://www.sharetribe.com/community).

- [Deploying Sharetribe to Heroku](https://gist.github.com/svallory/d08e9baa88e18d691605) by [svallory](https://github.com/svallory)


## Payments

PayPal and Stripe are the two available payment gateways integrated.

PayPal payments are only available on marketplaces hosted at [Sharetribe.com](https://www.sharetribe.com) due to special permissions needed from PayPal. We hope to add support for PayPal payments to the open source version of Sharetribe in the future.

Stripe can be used in the open-source alternative, as long as your country and currency are supported.

### Enable Stripe

Starting from release 7.2.0, Stripe is supported.

Stripe API keys will be encrypted when stored so it is important to configure your own random encryption key.
You should fill the `app_encryption_key` variable in the `config/config.yml` file with a long random string, unique to your project.

Stripe can be configured from the admin panel, in the "Payment settings" section. Instructions on how to get Stripe API keys can be found there.

If Stripe isn't automatically enabled in the admin panel after upgrading to 7.2.0, you should run the following commands in your Rails console, where `<ID>` is your marketplace ID (probably `1`):
`TransactionService::API::Api.processes.create(community_id: <ID>, process: :preauthorize, author_is_seller: true)`
and
`TransactionService::API::Api.settings.provision(community_id: <ID>, payment_gateway: :stripe, payment_process: :preauthorize, active: true)`.

## Versioning

Sharetribe follows [Semantic Versioning](http://semver.org/) where possible.

Given a version number MAJOR.MINOR.PATCH, increment the:

* MAJOR version when you make incompatible API changes,
* MINOR version when you add functionality in a backwards-compatible manner, and
* PATCH version when you make backwards-compatible bug fixes.

See the document [How Sharetribe applies Semantic Versioning](docs/semantic-versioning.md) to read more how Semantic Versioning is applied in practice.

## Changes

See [CHANGELOG.md](CHANGELOG.md) for detailed list of changes between releases.


## Upgrade

See [UPGRADE.md](UPGRADE.md) for information about actions needed when upgrading.

For production use we recommend you to upgrade only when new version is released and not to follow the master branch.

## Contribute

Would you like to make Sharetribe better?

See [CONTRIBUTING.md](CONTRIBUTING.md) for the steps to contribute.

## Release

See [RELEASE.md](RELEASE.md) for information about how to make a new release.


## Translation

Sharetribe uses [WebTranslateIt (WTI)](https://webtranslateit.com/en) for translations. If you'd like to translate Sharetribe to your language or improve existing translations, please ask for a WTI invitation. To get an invite, send an email to [info@sharetribe.com](mailto:info@sharetribe.com) and mention that you would like to become a translator.

All language additions and modifications (except for English) should be done through the WTI tool. We do not accept Pull Requests that add or modify languages (except English).


## Bug tracker

Browse open issues and submit new ones in [Github Issues](http://github.com/sharetribe/sharetribe/issues).

We are dedicating the Github Issue only for bugs in the Sharetribe codebase. For general questions, start a new thread in the [Community forum](https://www.sharetribe.com/community/) instead of opening a new Issue.

After you have opened a new issue, the team will handle it according to these instructions: [How to handle Github Issues](https://github.com/sharetribe/sharetribe/blob/master/docs/how-to-handle-github-issues.md)


## Documentation

More detailed technical documentation is located in [docs/](docs/)


## Community forum

The Sharetribe open source community forum is located at [https://www.sharetribe.com/community/](https://www.sharetribe.com/community/).

The forum is a great place to ask support and help for example with issues during the installation.


## MIT License

Sharetribe is open source under the MIT license. See [LICENSE](LICENSE) for details.
