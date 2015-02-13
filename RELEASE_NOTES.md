Sharetribe Release Notes
------------------------

This file contains description of changes in each Sharetribe release. It's good to read before updating from earlier versions of Sharetribe, as there might be major changes that the updater should notice, especially when first two numbers in the version numbering are increased.

General update instructions
---------------------------

When updating, always run the following commands to update gem set and database structure:
 - bundle install
 - rake RAILS_ENV=production db:migrate
 - check this file for changes between your old version and the one you are updating, and do the necessary manual operations if needed
 - if running on local instance (localhost), you need to precompile assets using "rake assets:precompile" once update is done

4.5.5
-----

Refactoring transaction database structure.
Booking possible for rental transactions.
Preparations for Paypal integrations.

4.5.4
-----

Ruby update to 2.1.2

You may need to run the following commands (if you are using RVM):

```bash
> rvm install ruby-2.1.2
> bundle install
```

4.5.3
-----

Added `sort_date` column, which can be used to sort listings.

Sphinx indecies have changed. You may need to rebuild your index by running:

Thinging Sphinx:

`rake ts:rebuild`

Flying Sphinx:

`rake fs:rebuild`

4.5.2
-----

Renewed conversation view UI

4.5.1
-----

New custom field type: Checkbox group

Sphinx indecies have changed. You may need to rebuild your index by running:

Thinging Sphinx:

`rake ts:rebuild`

Flying Sphinx:

`rake fs:rebuild`

4.5.0
-----

Ruby update to 2.1.1

This version updates Ruby to version 2.1.1. To get the new version running you need to update your Ruby installation
and run `bundle install` to update the gems.

Here are the list of commands you need:

```bash
> rvm cleanup all
> rvm get stable
> rvm install ruby-2.1.1
> bundle install
```

4.4.2
-----

Multiple listing images

This version includes a migration which reprocesses all listing images. This may potentially take quite a while.

4.4.1
-----

- Add numeric field

This update requires Sphinx search indexes and configurations to be updated.

4.4.0
-----
Major update to the data structure:

- CommunityCategories removed (a category can belong to only one community)
- ShareType renamed to TransactionType
- Admin user-interface for editing categories

There are migrations for all changes, but the possibility of running to issues when updating from earlier versions is considerable, so please back up your data before updating and if encountering any issues, please contact the core team to get help. (Latest instructions how to contact at: https://github.com/sharetribe/sharetribe)

4.3.1
-----
Admin can edit custom fields for listings

4.3.0
-----
Community admin can add custom fields for listings

4.2.1
-----
Payment improvements
- Send payment receipt email for buyers using Braintree gateway

4.2.0
-----
Improve payment system integrations and add first version of integration with Braintree Marketplace payments
 - Check config.example.yml for new config params needed e.g. if you want to run all the tests with Braintree API

4.1.1
-----
All user's emails are now in Emails table in DB and users can edit them all in the UI

4.1.0
-----
Much simpler system for creating organization accounts. The migrations that move old organizations to new model can be tricky if you have been using that feature extensively. If you run into problems just contact Sharetribe admins e.g. via Github issues. Most users should be able to update normally without issues.

4.0.0
-----
- New enhanced user interface with grid view, bigger images and cleaner look

3.1.3
-----
- added new translations

3.1.2
-----
- better map bubbles
- bug fixes

3.1.1
-----
Small improvements that enhance stability and speed.


3.1.0
-----

Lot of fixes in different places. Biggest change is probably that categories are now customizable and some pages can be edited directly. Also more assets are stored to Amazon S3 by default.

There was a bit too long gap between the releases, but if you get trouble with this update, don't hesitate to contact us, preferably at: https://github.com/sharetribe/sharetribe/issues

3.0.3
-----

 Small improvements and bug fixes. Most important for installations of open source versions is that the earlier version complained about missing ss-pika font pack files, but those dependencies are now better handled.

3.0.2
-----

This was a big change in the whole user interface to make Sharetribe UI responsive for different screensizes.
There were challenges that delayed the publishing of the stable open source version and that's why so many changes are packed in one update. In the database side there are also major changes, e.g. changing categories to be dynamic and customizable by community.

There are migrations for all changes, but the possibility of running to issues when updating from earlier versions is considerable, so please back up your data before updating and if encountering any issues, please contact the core team to get help. (Latest instructions how to contact at: https://github.com/sharetribe/sharetribe)

2.4.7
-----

New logic and layout for community updates email

2.4.6
-----

Add translations to ATOM feed for share type and listing type

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

