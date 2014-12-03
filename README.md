# Sharetribe

[![Build Status](https://travis-ci.org/sharetribe/sharetribe.svg?branch=master)](https://travis-ci.org/sharetribe/sharetribe) [![Dependency Status](https://gemnasium.com/sharetribe/sharetribe.png)](https://gemnasium.com/sharetribe/sharetribe) [![Code Climate](https://codeclimate.com/github/sharetribe/sharetribe.png)](https://codeclimate.com/github/sharetribe/sharetribe) [![Coverage Status](https://coveralls.io/repos/sharetribe/sharetribe/badge.png)](https://coveralls.io/r/sharetribe/sharetribe)

Sharetribe is an open source platform you can use to create your own peer-to-peer marketplace.

Would you like to set up your marketplace in a minute without touching code? [Head to Sharetribe.com](https://www.sharetribe.com).

Want to get in touch? Email [info@sharetribe.com](mailto:info@sharetribe.com)


## Installation

Note: If you encounter problems with the installation, you can try asking for help from the developer community in our [developer chatroom](https://www.flowdock.com/invitations/4f606b0784e5758bfdb25c30515df47cff28f7d5-main).

* Before you get started, you need to have or install the following:
  * Ruby (we use currently version 2.1.2 and don't guarantee everything working with others. If you need multiple versions of Ruby, [RVM](https://rvm.io//) can help.)
  * [RubyGems](http://rubygems.org/)
  * Bundler `gem install bundler`
  * [Git](http://help.github.com/git-installation-redirect)
* Get the code (git clone is probably easiest way: `git clone git://github.com/sharetribe/sharetribe.git`)
* Go to the root folder of Sharetribe
* Copy the example database configuration file as database.yml, which will be used to read the database information: `cp config/database.example.yml config/database.yml`
* You need to have a database available for Sharetribe and a DB user account that has access to it. We have only used MySQL, so we give no guarantees of things working with others (e.g. PostgreSQL). (If you are going to do development you should have separate databases for development and testing also).
  * If you are new to MySQL:
  * You can install MySQL Community Server two ways:
      1. If you are on a Mac, use homebrew: `$ brew install mysql` (*highly* recommended)
      2. Download a [MySQL installer from here](http://dev.mysql.com/downloads/mysql/)
    * If you are using Mac OS X, consider installing `MySQL.prefPane` as a server startup/shutdown tool. It is packaged with the MySQL downloadable installer, but can be easily installed as a stand-alone.
  * [These commands](https://gist.github.com/804314) can help you in creating a user and databases.
* Edit details according to your database to `config/database.yml` (if you are not going to develop Sharetribe, it's enough to fill in the production database)
  * Probably you only need to change the passwords to the same that you used when creating the databases.
* Install Sphinx. Version 2.1.4 has been used successfully, but probably also bit newer and older versions will work. See [Sphinx installation instructions](http://pat.github.com/ts/en/installing_sphinx.html) (no need to start it yet. You can try running `searchd` command, but it should fail at this point complaining about missing config)
* Install [Imagemagick](http://www.imagemagick.org)
* run `bundle install` in the project root directory (sharetribe) to install required gems
* (In the following commands, leave out the `RAILS_ENV=production` part if you want to get Sharetribe running in development mode.) Load the database structure to your database: `rake RAILS_ENV=production db:schema:load`
* run sphinx index `rake RAILS_ENV=production ts:index`
* start sphinx daemon `rake RAILS_ENV=production ts:start`
* If you want to run Sharetribe in production mode (i.e. you are not developing the software) you'll need to precompile the assets. This puts the Javascript and CSS files in right places. Use command: `rake assets:precompile`
* If you want to enable Sharetribe to send email locally (in the development environment), you might want to change the email settings in the config file. There is an example of configuring settings using a gmail account, but you can also use any other SMTP server. If you do not touch the settings, the development version works otherwise normally but might crash in instances where it tries to send email (like when sending a message to another user).
* Invoke the delayed job worker on your local machine: `rake RAILS_ENV=production jobs:work`. You should see "Starting job worker" and then the process stays open. The worker processes tasks that are done in the background, like processing images and sending email notifications. To exit the worker, press ctrl+c.
* Create your marketplace. Quickest way is to open console and run the commands below. Before running, choose your marketplace subdomain, type (product, rental or service), languge and country and modify the command below to include your choices. Then run `rails console production` and run the commands with your values:

```ruby
marketplace_parameters = {
 marketplace_name: "your_chosen_subdomain_here",
 marketplace_type: "product",
 marketplace_country: "US",
 marketplace_language: "en"
}

MarketplaceService::API::Marketplaces::create(marketplace_parameters)

```
* Start the server. The simplest way is to use command `rails server` which will start it on Webrick, which is good option for development use.
  * To start the server in production environment, use command `rails server -e production`



* Go to the marketplace you created (your\_chosen\_subdomain\_here.yourdomain.com or your\_chosen\_subdomain_here.lvh.me:3000) and sign up as a new user. The first registered user will automatically become an administrator of that marketplace.

Congrats! You should be now able to access your marketplace and modify it from the admin area.

See also:

* [How to customize your marketplace?](docs/customize-marketplace.md)

### Experimental: Docker container installation

Prerequisite: You have to have _docker_ and _fig_ installed. If you are on a non-linux OS, you need to have _vagrant_. If you can successfully run `docker info`, then you should be ok to go.

#### OSX Vagrant setup

Run:

```bash
vagrant up
export DOCKER_HOST=tcp://192.168.33.10   # Set Docker CLI to connect to Vagrant box. This IP is set in Vagrantfile
export DOCKER_TLS_VERIFY=                # disable TLS
docker info                              # this should run ok now
```

1. Modify `config/database.yml`. The easiest way is to use `database.docker.yml`

  `cp config/database.docker.yml config/database.yml`

1. Load schema (only on the first run)

  `fig run web /bin/bash -l -c 'bundle exec rake db:schema:load'`

1. Create a marketplace (only on the first run)

  `fig run web /bin/bash -l -c 'rails console'`

  Type this to console:

  ```ruby
  marketplace_parameters = {
  marketplace_name: "docker",
  marketplace_type: "product",
  marketplace_country: "US",
  marketplace_language: "en"
  }

  MarketplaceService::API::Marketplaces::create(marketplace_parameters)
  ```

  Exit the console, type `exit`

1. Run the app

  `fig up`

1. Set lvh.me to point to docker IP

  Modify your `/etc/hosts` file. If you're in Linux, point 127.0.0.1 to docker.lvh.me. If you are on OSX (or Windows), point 192.168.33.10 to docker.lvh.me

1. All done! Open your browser and URL http://docker.lvh.me:3000

### Advanced settings

* Default configurations are in `config/config.default.yml`. If you need to change these configs, it's recommended to create a file `config/config.yml`. The configurations in user-specific configuration file will override the default configurations. You can also set configurations to environment variables.
* It's not recommended to server static assets from Rails server in production. Instead, you should serve assets from Amazon S3 or use Apache/Nginx server in from. In this case, you'll need to set the value of `serve_static_assets_in_production` to `false`

## Payments

Sharetribe's open source version supports payments using [Braintree Marketplace](https://www.braintreepayments.com/features/marketplace). To enable payments with Braintree you need to have a legal business in The United States. You can sign up for Braintree [here](https://signups.braintreepayments.com/). Then you need to create a new row to the payment gateways table with your Braintree merchant_id, master_merchant_id, public_key, private_key and client_side_encryption_key.

Right now PayPal payments are only available in marketplaces hosted at [Sharetribe.com](https://www.sharetribe.com), because they require special permissions from PayPal. We hope to bring support for PayPal payments also to the open source version of Sharetribe in the future.

## Updating

See [release notes](RELEASE_NOTES.md) for information about what has changed and if special tasks are needed to update.

## Contributing

Would you like to make Sharetribe better? [Here's a basic guide](CONTRIBUTING.md).

## Translation

We use a tool called WebTranslateIt (WTI) for translations. If you'd like to translate Sharetribe to your language or improve existing translations, please use WTI for that. You need an invite to use WTI. To get an invite, email info@sharetribe.com and mention that you would like to become a translator.

## Known issues

See http://github.com/sharetribe/sharetribe/issues and please report any issues you find.

## Developer docs

* [Testing](docs/testing.md)
* [SCSS coding guidelines](docs/scss-coding-guidelines.md)
* [Delayed job priorities](docs/delayed-job-priorities.md)
* [Cucumber testing Do's and Don'ts](docs/cucumber-do-dont.md)

## MIT License

Sharetribe is open source under MIT license. See [LICENSE](LICENSE) file for details.
