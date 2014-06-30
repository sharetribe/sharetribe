# Deployment rookie guide for sharetribe

##  acknowledgment:
**this guide is written from a guy with soft server skills and it is most likely mash-up from different sources and if i was able to then you are too, don't worry and you will rock at the end.**
***

### Little git work

1. clone sharetribe git repository to your machine [or fork it and clone the forked one]

`git clone https://github.com/sharetribe/sharetribe.git`

1. create new git repository and add new remote [if you have not forked the original one]

`git remote add some_new_origin https://github.com/user/repo.git`

### Setting up VPS on Digital Ocean

I found this great [guide](https://gorails.com/deploy/ubuntu/14.04) and i can't write anything better than this, follow every step to set-up your own VPS with nginx and passenger. But before you do finish this reading first !!

* What i have chosen: 1GB/1CPU for 10USD/month

* I have installed RVM with ruby '2.1.1' with MySQL option - from the options what guide above give you

* You will need a domain which is easy set-up on digital ocean too (DNS section by adding A record) this domain you will provide in two places: in /etc/nginx/sites-enabled/default and in config.yml in our sharetribe code

* right after you finish adding ssh keys to server i recommend to lock ssh with login/password, follow this [guide](http://lani78.com/2008/08/08/generate-a-ssh-key-and-disable-password-authentication-on-ubuntu-server/)

* When you will be finishing installing MySQL don't logout from ssh session yet and install more dependencies for sharetribe:

````
- sudo apt-get install sphinxsearch
- sudo apt-get install imagemagick
````

* i don't install nodejs as engine for precompiling rails assets, because i was facing some memory issues on digital ocean and i rather use rubyracer && execjs gems.

so at the very end i added to my Gemfile:

````
group :development do
  gem 'capistrano', '~> 3.1.0'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-rails', '~> 1.1.1'
  gem 'capistrano-rvm', github: "capistrano/rvm"
end

group :production do
  # needed for capistrano - delayed job
  gem 'daemons'
  # needed for precompiling assets
  gem 'therubyracer'
  gem 'execjs'
end
````

### Don't deploy yet still few things to do:

1. `cp config/config.example.yml config/config.yml` and provide your domain name and smtp settings at minimum

1. add `set :rails_env, "production" #added for delayed job` in config/deploy/production.rb

1. add `set :thinking_sphinx_roles, :app` in config/deploy/production.rb (to let know for thinking/sphinx/capistrano where is our search server - i am not cap master, but its not working without :-)

1. add following to config/thinking_sphinx.yml to production settings (preserve thinking sphinx across releases)

````
  pid_file: /home/deploy/sharetribe/shared/tmp/pids/searchd.pid
  indices_location: /home/deploy/sharetribe/shared/db/sphinx
  configuration_file: /home/deploy/sharetribe/shared/config/production.sphinx.conf
  binlog_path: /home/deploy/sharetribe/shared/binlog
````

1. add `require 'thinking_sphinx/capistrano'` to Capfile

1. create capistrano3 dalayed job tasks follow this [guide](https://github.com/collectiveidea/delayed_job/wiki/Delayed-Job-tasks-for-Capistrano-3)

1. lock money-rails version in Gemfile `gem 'money-rails', '0.8.1'`

1. to process payments u need add `config.add_rate "USD", "EUR", rate_number` to config/initializers/money.rb if you leave default currency EUR (i think)

1. commit and push your changes to the new repository which matches with repository you specified in config/deploy.rb - the forked one or the new remote)

### Deploy it!

the first `cap production deploy` is unsuccessful right? because it's complaining about missing database.yml from shared directory? 

````
ssh deploy@server
cd sharetribe/shared/config
touch database.yml # and edit
````

again `cap production deploy` and now the code should be there, that is great but still not finished. Still a little of work:

````
ssh deploy@server

usermod -a -G deploy sphinxsearch //lets add sphinxsearch to deploy group in order to have access /shared directory

cd sharetribe/current

RAILS_ENV=production bundle exec rake db:create
RAILS_ENV=production bundle exec rake db:structure:load
RAILS_ENV=production bundle exec rails console

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
````

from your local now you can:

````
cap production deploy
cap production deploy:restart
cap production delayed_job:start
cap production thinking_sphinx:start
cap production thinking_sphinx:index

````
 and see more with `cap -T`

**I really would like to hear your experience with this guide, please do share how to improve and if i miss something**