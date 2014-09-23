# Sharetribe

[![Build Status](https://travis-ci.org/sharetribe/sharetribe.svg?branch=master)](https://travis-ci.org/sharetribe/sharetribe) [![Dependency Status](https://gemnasium.com/sharetribe/sharetribe.png)](https://gemnasium.com/sharetribe/sharetribe) [![Code Climate](https://codeclimate.com/github/sharetribe/sharetribe.png)](https://codeclimate.com/github/sharetribe/sharetribe) [![Coverage Status](https://coveralls.io/repos/sharetribe/sharetribe/badge.png)](https://coveralls.io/r/sharetribe/sharetribe)

Sharetribe is a peer-to-peer marketplace platform built with Ruby on Rails.

See www.sharetribe.com for more info and links to example communities

NOTE: The open source community of Sharetribe is still young and some things like installation may not yet be the smoothest you've encountered. However, we're eager to welcome new people to use the open source Sharetribe, and if you decide to install it yourself, feel free to ask for support at the [Sharetribe Developers Flowdock](https://www.flowdock.com/invitations/4f606b0784e5758bfdb25c30515df47cff28f7d5-main)

## Installation

NOTE: If you try installing and encounter problems, please report them for example in [Issues](https://github.com/sharetribe/sharetribe/issues) or at [Flowdock](https://www.flowdock.com/invitations/4f606b0784e5758bfdb25c30515df47cff28f7d5-main). We try to help you and enhance the documentation.


Below the installation instructions there is space for Operating system-specific tips, so if you have problems, check there, and if you get your problem solved, add instructions to the tips section.


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
* (In the following commands, leave out the `RAILS_ENV=production` part if you want to get Sharetribe running in development mode.) Load the database structure to your database: `rake RAILS_ENV=production db:structure:load`
* run sphinx index `rake RAILS_ENV=production ts:index`
* start sphinx daemon `rake RAILS_ENV=production ts:start`
* If you want to run Sharetribe in production mode (i.e. you are not developing the software) you'll need to precompile the assets. This puts the Javascript and CSS files in right places. Use command: `rake assets:precompile`
* If you want to enable Sharetribe to send email locally (in the development environment), you might want to change the email settings in the config file. There is an example of configuring settings using a gmail account, but you can also use any other SMTP server. If you do not touch the settings, the development version works otherwise normally but might crash in instances where it tries to send email (like when sending a message to another user).
* Invoke the delayed job worker on your local machine: `rake RAILS_ENV=production jobs:work`. You should see "Starting job worker" and then the process stays open. The worker processes tasks that are done in the background, like processing images and sending email notifications. To exit the worker, press ctrl+c.
* Start the server. The simplest way is to use command `rails server` which will start it on Webrick, which is good option for development use.
  * To start the server in production environment, use command `rails server -e production`
* Sharetribe server can serve multiple Sharetribe marketplaces (tribes) that are separated by subdomains. You need at least one community to use Sharetribe. To create a community and add some default transaction type and category there, start the Rails Console: `rails console production` and choose the name and subdomain for your community and insert them in the following commands:

```ruby
c = Community.create(:name => "your_chosen_name_here", :domain => "your_chosen_subdomain_here")

tt = c.transaction_types.create(:type => "Sell",
 :price_field => 1,
 :price_quantity_placeholder => nil);

tt_trans = TransactionTypeTranslation.create(:transaction_type_id => tt.id,
 :locale => "en",
 :name => "Sell",
 :action_button_label => "Buy");
ca = c.categories.create;
ca_trans = CategoryTranslation.create(:category_id => ca.id,
 :locale => "en",
  :name => "Items");
CategoryTransactionType.create(:category_id => ca.id, :transaction_type_id => tt.id)

```

* go to your selected community address (your\_chosen\_subdomain\_here.yourdomain.com or your\_chosen\_subdomain_here.lvh.me:3000) and register as a user. The first registered user will be automatically made as an admin in that community.

Congrats! You should be now able to access your marketplace.

See also:

* [How to customize your marketplace?](docs/customize-marketplace.md)

### Advanced settings

* Default configurations are in `config/config.default.yml`. If you need to change these configs, it's recommended to create a file `config/config.yml`. The configurations in user-specific configuration file will override the default configurations. You can also set configurations to environment variables.
* It's not recommended to server static assets from Rails server in production. Instead, you should serve assets from Amazon S3 or use Apache/Nginx server in from. In this case, you'll need to set the value of `serve_static_assets_in_production` to `false`

### Tips for different platforms and OS

#### Windows

* The core team is doing development on macs and running servers on linux, so we don't have experience on running Sharetribe on Windows. It is possible, but with guidance you might have to rely on the community support.
  * There is a (bit outdated) [separate guide for windows installation](https://github.com/tlsalmin/kassi/wiki/HOW-TO-install-kassi-in-Windows-(for-Development-only)) written by [vbtdung](https://github.com/vbtdung)
* Note that the installation instructions on this page are written for *nix-based systems so you need to change the commands a little to make them work in windows (e.g. `cp` becomes `copy` in Windows)
* You may need to add few windows specific gems to Gemfile. Versions prior to 2.3.0 included these, but because they caused trouble running Sharetribe on Heroku, we decided to remove them from the default Gemfile. You can just add these lines to Gemfile and run `bundle install`.

```bash
gem 'win32console', :platforms => [:mswin, :mingw]
gem 'win32-process', :platforms => [:mswin, :mingw]
```

#### Mac Os X

* If you are using MySQL, please note that Mac OS X 10.6 requires a 64-bit version of MySQL.
* RVM requires both Xcode and Command Line Tools for Xcode to be installed
  * Install Xcode from App Store
  * To install Command Line Tools for Xcode, open Xcode and from the application menu, select Xcode > Open Developer Tools > More Developer Tools...

#### Ubuntu (and Linux in general)

* If, during precompile, you face an error like `Could not find a JavaScript runtime. See https://github.com/sstephenson/execjs for a list of available runtimes.`, you have to install nodejs. Execute `sudo apt-get install nodejs` and run precompile again.

* These are the bash commands I used to install Sharetribe on a fresh Ubuntu 12.10 box:

```bash
- sudo aptitude install ruby2.1.1
- sudo gem install bundler
- sudo aptitude install git
- git clone git://github.com/sharetribe/sharetribe.git
- cd sharetribe
- cp config/database.example.yml config/database.yml
- sudo aptitude install mysql-server-5.5
- sudo mysql_secure_installation
- <execute 2 production SQL commands>
- emacs config/database.yml
	- edit the pw of "sharetribe_production"
- cp config/config.example.yml config/config.yml
- emacs config/config.yml
	- check all once
- sudo aptitude install sphinxsearch
- sudo aptitude install imagemagick
- sudo aptitude install build-essential mysql-client libmysql-ruby libmysqlclient-dev
- sudo gem install mysql2 -v 0.2.7
- sudo aptitude install libxml2-dev libxslt-dev
- emacs Gemfile.lock
	- change money-rails (0.8.0) to money-rails (0.8.1)
- bundle install
- rake RAILS_ENV=production db:structure:load
- (note: if you ever want to uninstall all ruby gems)
	- sudo su
	- gem list | cut -d" " -f1 | xargs gem uninstall -aIx
- sudo aptitude install nodejs
- rake RAILS_ENV=production db:seed
- rake RAILS_ENV=production ts:index
- rake RAILS_ENV=production ts:start
- emacs app/assets/stylesheets/application.scss.erb
	- prepend this to the <% %> block at the top:
		require "#{Rails.root}/app/helpers/scss_helper.rb"
- rake assets:precompile
- to enable logs in production (Passenger+Apache)
	- emacs config/application.rb
	- comment out the lines:
		if Rails.env.production? || Rails.env.staging?
			config.logger = Logger.new(STDOUT)
			config.logger.level = Logger.const_get(ENV['LOG_LEVEL'] ? ENV['LOG_LEVEL'].upcase : 'INFO')
		end
- emacs app/views/layouts/application.haml
	- delete the last include IE9 javascript imports
- sudo aptitude install apache2 libapache2-mod-passenger
- sudo gem install passenger
- edit the apache site config file
- rake RAILS_ENV=production jobs:work
```

See [New guide for deployment using capistrano from scratch to VPS](docs/vps-deployment.md)

## Updating

See [RELEASE_NOTES.md](RELEASE_NOTES.md) for information about what has changed and if special tasks are needed to update.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for general contributing guidelines.

## Known issues

See http://github.com/sharetribe/sharetribe/issues and please report any issues you find

## Developer docs

* [Testing](docs/testing.md)
* [SCSS coding guidelines](docs/scss-coding-guidelines.md)
* [Delayed job priorities](docs/delayed-job-priorities.md)
* [Cucumber testing Do's and Don'ts](docs/cucumber-do-dont.md)

## MIT License

Sharetribe is open source under MIT license. See [LICENSE](LICENSE) file for details.
