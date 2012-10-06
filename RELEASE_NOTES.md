Sharetribe Release Notes
------------------------

This file contains description of changes in each Sharetribe release. It's good to read before updating from earlier versions of Sharetribe, as there might be major changes that the updater should notice, especially when first two numbers in the version numbering are increased.

General update instructions 
---------------------------

When updating, always run the following commands to update gem set and database structure:
 - bundle install
 - rake RAILS_ENV=production db:migrate
 -  And check this file for changes between your old version and the one you are updating, and do the necessary manual operations if needed.

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

