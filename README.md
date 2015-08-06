# Sharetribe

[![Build Status](https://travis-ci.org/sharetribe/sharetribe.svg?branch=master)](https://travis-ci.org/sharetribe/sharetribe) [![Dependency Status](https://gemnasium.com/sharetribe/sharetribe.png)](https://gemnasium.com/sharetribe/sharetribe) [![Code Climate](https://codeclimate.com/github/sharetribe/sharetribe.png)](https://codeclimate.com/github/sharetribe/sharetribe) [![Coverage Status](https://coveralls.io/repos/sharetribe/sharetribe/badge.png)](https://coveralls.io/r/sharetribe/sharetribe)

Sharetribe is an open source platform to create your own peer-to-peer marketplace.

Would you like to set up your marketplace in one minute without touching code? [Head to Sharetribe.com](https://www.sharetribe.com).

Want to get in touch? Email [info@sharetribe.com](mailto:info@sharetribe.com)


## Installation

Note: If you encounter problems with the installation, ask for help from the developer community in our [developer chatroom](https://www.flowdock.com/invitations/4f606b0784e5758bfdb25c30515df47cff28f7d5-main). When you join, please use threads. Instructions for this and other chat-related things can be found at [Flowdock's chat instructions](https://www.flowdock.com/help/chat).

Before you get started, the following needs to be installed:
  * Ruby. Version 2.1.2 is currently used and we don't guarantee everything works with other versions. If you need multiple versions of Ruby, [RVM](https://rvm.io//) is recommended.
  * [RubyGems](http://rubygems.org/)
  * Bundler: `gem install bundler`
  * [Git](http://help.github.com/git-installation-redirect)
  * A database. Only MySQL has been tested, so we give no guarantees that other databases (e.g. PostgreSQL) work. You can install MySQL Community Server two ways:
    1. If you are on a Mac, use homebrew: `brew install mysql` (*highly* recommended). Also consider installing the [MySQL Preference Pane](https://dev.mysql.com/doc/refman/5.1/en/osx-installation-prefpane.html) to control MySQL startup and shutdown. It is packaged with the MySQL downloadable installer, but can be easily installed as a stand-alone.
    2. Download a [MySQL installer from here](http://dev.mysql.com/downloads/mysql/)
  * [Sphinx](http://pat.github.com/ts/en/installing_sphinx.html). Version 2.1.4 has been used successfully, but newer versions should work as well.
  * [Imagemagick](http://www.imagemagick.org). If you're using OS X and have Homebrew installed, install it with `brew install imagemagick`

1. Get the code. Cloning this git repo is probably easiest way: `git clone git://github.com/sharetribe/sharetribe.git`
1. Go to the sharetribe project root directory
1. Create a database.yml file by copying the example database configuration: `cp config/database.example.yml config/database.yml`
1. Create the required databases with [these commands](https://gist.github.com/804314). If you're not planning on developing Sharetribe, you only need the sharetribe_production database.
1. Add your database configuration details to `config/database.yml`
  * You will probably only need to fill in the password for the database(s)
1. Run `bundle install` in the project root directory to install the required gems
1. Initialize your database: `bundle exec rake db:schema:load`
1. Run Sphinx index: `bundle exec rake ts:index`
1. Stat the Sphinx daemon: `bundle exec rake ts:start`
1. Install and run [Mailcatcher](http://mailcatcher.me) to receive sent emails locally:
    1. `gem install mailcatcher`
    1. `mailcatcher`
    1. Create a `config/config.yml` file and add the following lines to it:
      ```yml
      mail_delivery_method: smtp
      smtp_email_address: "localhost"
      smtp_email_port: 1025
      ```
    1. Open `http://localhost:1080` in your browser
1. Invoke the delayed job worker: `bundle exec rake jobs:work`
1. In a new console, open the project root folder and start the server. The simplest way is to use the included Webrick server: `bundle exec rails server`

Congratulations! Sharetribe should now be up and running. Open a browser and go to the server URL (e.g. http://lvh.me:3000). Fill in the form to create a new marketplace and admin user. You should be now able to access your marketplace and modify it from the admin area.


### Setting up Sharetribe for production

Steps 1-6 from above need to be done before performing these steps.

1. Initialize your database: `bundle exec rake RAILS_ENV=production db:schema:load`
1. Run Sphinx index: `bundle exec rake RAILS_ENV=production ts:index`
1. Start the Sphinx daemon: `bundle exec rake RAILS_ENV=production ts:start`
1. Precompile the assets: `bundle exec rake assets:precompile`
1. Invoke the delayed job worker: `bundle exec rake RAILS_ENV=production jobs:work`
1. In a new console, open the project root folder and start the server: `bundle exec rails server -e production`

It is not recommended to serve static assets from a Rails server in production. Instead, you should serve assets from Amazon S3 or use an Apache/Nginx server. In this case, you'll need to set the value of `serve_static_assets_in_production` to `false` in `config/config.yml`.


### Advanced settings

Default configuration settings are stored in `config/config.default.yml`. If you need to change these, we recommend creating a `config/config.yml` file to override these values. You can also set configuration values to environment variables.


### Experimental: Docker container installation

#### Prerequisite

Prerequisite: Docker and Fig need to be installed. If you are on a non-linux OS, you also need to have Vagrant. If you can successfully run `docker info`, you should be good to go.

```bash
brew cask install virtualbox
brew cask install vagrant
brew install docker
brew install fig
```

Run:

```bash
vagrant up
export DOCKER_HOST=tcp://192.168.33.10:2375   # Set Docker CLI to connect to Vagrant box. This IP is set in Vagrantfile
export DOCKER_TLS_VERIFY=                     # disable TLS
docker info                                   # this should run ok now
```

#### Sharetribe installation

1. Modify `config/database.yml`. The easiest way is to use the provided `database.docker.yml`

  `cp config/database.docker.yml config/database.yml`

1. Load schema (only on the first run)

  `fig run web /bin/bash -l -c 'bundle exec rake db:schema:load'`

1. Run the app

  `fig up web`

1. Set docker.lvh.me to point to the docker IP

  Modify your `/etc/hosts` file. If you're in Linux, point 127.0.0.1 to docker.lvh.me. If you are on OSX (or Windows), point 192.168.33.10 to docker.lvh.me

1. All done! Open http://docker.lvh.me:3000 in your browser and create a new marketplace with the name `docker`

#### Docker development tips and tricks

If you are planning to use Docker for development, here are some tips and tricks to make the development workflow smoother.

1. Add the `figrun` function to your zsh/bash config.

  Here is an example for ZSH:

  ```zsh
  figrun() {
    PARAMS="$*"
    CMD="bundle exec ${PARAMS}"
    fig run web /bin/bash -l -c "$CMD"
  }
  ```

  With this function, you can run commands on the web container like this:

  ```
  figrun rake routes
  ```

2. Use Zeus

  First, add `figzeus` helper function to your zsh/bash config.

  Here is an example for ZSH:

  ```zsh
  figzeus() {
    PARAMS="$*"
    CMD="zeus ${PARAMS}"
    fig run web /bin/bash -l -c "$CMD"
  }
  ```

  To use Zeus, do not start server by saying `fig up web`! Do this instead:

  Start Zeus server in one terminal tab:

  ```zsh
  fig up zeus
  ```

  In another tab, start rails server:

  ```zsh
  figzeus s
  ```

## Payments

Sharetribe's open source version supports payments using [Braintree Marketplace](https://www.braintreepayments.com/features/marketplace). To enable payments with Braintree, you need to have a legal business in the United States. You can sign up for Braintree [here](https://signups.braintreepayments.com/). Once that's done, create a new row in the payment gateways table with your Braintree merchant_id, master_merchant_id, public_key, private_key and client_side_encryption_key.

PayPal payments are only available on marketplaces hosted at [Sharetribe.com](https://www.sharetribe.com) due to special permissions needed from PayPal. We hope to add support for PayPal payments to the open source version of Sharetribe in the future.

## Updating

See [release notes](RELEASE_NOTES.md) for information about what has changed and if actions are needed to upgrade.

## Contributing

Would you like to make Sharetribe better? [Here's a basic guide](CONTRIBUTING.md).

## Translation

We use WebTranslateIt (WTI) for translations. If you'd like to translate Sharetribe to your language or improve existing translations, please ask for a WTI invitation. To get an invite, send an email to info@sharetribe.com and mention that you would like to become a translator.

## Known issues

Browse open issues and submit new ones at http://github.com/sharetribe/sharetribe/issues.

## Developer docs

* [Testing](docs/testing.md)
* [SCSS coding guidelines](docs/scss-coding-guidelines.md)
* [Delayed job priorities](docs/delayed-job-priorities.md)
* [Cucumber testing Do's and Don'ts](docs/cucumber-do-dont.md)

## MIT License

Sharetribe is open source under the MIT license. See [LICENSE](LICENSE) for details.
