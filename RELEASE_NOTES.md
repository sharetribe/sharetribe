Sharetribe Release Notes
------------------------

This file contains description of changes in each Sharetribe release. It's good to read before updating from earlier versions of Sharetribe, as there might be major changes that the updater should notice, especially when first two numbers in the version numbering are increased.

General update instructions 
---------------------------

When updating, always run the following commands to update gem set and database structure:
 - bundle install
 - rake RAILS_ENV=production db:migrate
 -  And check this file for changes between your old version and the one you are updating, and do the necessary manual operations if needed.

2.4.5
-----

- Tiny fixes in emails and Atom feed title

2.4.4
-----

- bug fixes in statistics and FB login
- language updates

2.4.3
-----

- Dashboard changes to remove the pricing page
- updates to FAQ
- bug fixes

2.4.2
-----

- bug fixes
- better support for Travis CI
- started improving the tribe updates mail
- better log level control with Heroku hosting

2.4.1
-----

just a small fix to a bug the prevented calculating statistics in non-active tribes

2.4.0
-----

Update Rails version to 3.2, enable asset pipeline and update many gems to latest versions

### Update instructions from 2.3.10 to 2.4.0 ###

 - "bundle install" command should do required updates for gems.
 - if you have modified some static assets (CSS, JS, images) you might need to move them to app/assets directory. See the current directory structure for example
 - the current deploy process expects that the assets get precompiled at the server. You might need to add "rake assets:precompile" to you build process.


### Changes ###

 - Updated Rails version to 3.2.9
 - Updated many gems to latest versions
 - Enabled Asset Pipeline and changed the directory structure for assets
 


2.3.10
------

Improvements to newsletter

2.3.9
-----

Possibility to send occasional html newsletters and a profile setting to toggle those on/off.

2.3.8
-----

Add possibility to create tribe as invite only. Also disable problematic FB login on dashboard.

2.3.7
-----

Updated many gem dependencies, made FB login visible by default, few bug fixes with statistics and translations

2.3.6
-----

Fix bug with email delivery method for newsletters

2.3.5
-----

Bug fixes in API image urls + language updates

2.3.4
-----

Bug fixes for demo script

2.3.3
-----

Demo script and bug fixes

### Changes ###

 - Demo script that can populate the database based on spreadsheet file. Now done for English and French. More languages can be added by following the same logic.
 - Fix S3 image links to be https to avoid browser warnings 

2.3.2
-----

Add possibility to merge user accounts (at the moment only using Rails console)

2.3.1
-----

Better support for Travis Continuous integration + some tribe customizations

2.3.0
-----

This release updated used Ruby version to 1.9.3. and added support for running Sharetribe in Heroku.

### Update instructions from 2.2.8 to 2.3.0 ###

 - You need to update your Ruby version to 1.9.3. Installing RVM can help manage multiple Ruby versions if needed.
 - database.yml must be updated manually. Change "adapter: mysql" to "adapter: mysql2", see database.example.yml for example
 - config.yml needs to be updated with new additions. See config.example.yml for example. E.g. you should add part for staging, even if there's no need to configure it specially.
 

### Changes ###

 - Ruby updated from version 1.8.7 to 1.9.3
 - Rails updated from version 3.0.0 to 3.0.17
 - Sharetribe can now easily be hosted in Heroku
 - Image attachments can be stored in Amazon S3
 - Some URL redirection functionality is moved to ApplicationController (earlier had to be done on web server side, which is not possible with Heroku)
 - Lot of gem updates, e.g. mysql to mysql2 which requires updating database.yml
 - Added a staging environment (optional to use)
 


2.2.8
-----

The last release using Ruby 1.8.7

