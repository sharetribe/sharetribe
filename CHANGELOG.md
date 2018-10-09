# Change Log

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/) where possible.

This file follows the best practices from [keepachangelog.com](http://keepachangelog.com/).

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [7.4.0] - 2018-10-09

### Added

- View Listings page in the admin panel [#3340](https://github.com/sharetribe/sharetribe/pull/3340)
- Locations section in the custom landing pages [#3341](https://github.com/sharetribe/sharetribe/pull/3341)
- Background color and image for any section [#3296](https://github.com/sharetribe/sharetribe/pull/3296)
- Custom fields for user profiles [#3332](https://github.com/sharetribe/sharetribe/pull/3332)
- Add a section button for info-2-columns and info-3-columns in the custom landing pages [#3362](https://github.com/sharetribe/sharetribe/pull/3362)
- File name in the design tab and profile settings to show the stored file [#3364](https://github.com/sharetribe/sharetribe/pull/3364)
- Allow markdown in user profiles "About you" section [#3370](https://github.com/sharetribe/sharetribe/pull/3370)
- "Expired" status in View listings page [#3387](https://github.com/sharetribe/sharetribe/pull/3387)
- Allow spaces at the end of the e-mails in signup form [#3394](https://github.com/sharetribe/sharetribe/pull/3394)
- Added Puerto Rico as a Stripe supported country [#3399](https://github.com/sharetribe/sharetribe/pull/3399)
- Added support for INR with PayPal [#3416](https://github.com/sharetribe/sharetribe/pull/3416)
- Added support for ARS with PayPal [#3415](https://github.com/sharetribe/sharetribe/pull/3415)
- Direct link to the admin panel when logging in as admin user[#3414](https://github.com/sharetribe/sharetribe/pull/3414)
- Added checkmarks to the user fields [#3441](https://github.com/sharetribe/sharetribe/pull/3441)
- Added the use of session token in Google's autocomplete feature [#3401](https://github.com/sharetribe/sharetribe/pull/3401)
- Icons to payment provider's page [#3444](https://github.com/sharetribe/sharetribe/pull/3444)

### Changed

- Rename admin panel sections [#3350](https://github.com/sharetribe/sharetribe/pull/3350)
- Rename save listings button [#3355](https://github.com/sharetribe/sharetribe/pull/3355)
- Video section variations on the custom landing pages [#3367](https://github.com/sharetribe/sharetribe/pull/3367)
- Renamed the default category to "default category" [#3362](https://github.com/sharetribe/sharetribe/pull/3362)
- Allow links in the custom user text fields [#3373](https://github.com/sharetribe/sharetribe/pull/3373)
- Google maps dynamic map for static maps in the listing page [#3382](https://github.com/sharetribe/sharetribe/pull/3382)
- Change Static map for embedded maps in the listing page [#3395](https://github.com/sharetribe/sharetribe/pull/3395)
- Update to Circle CI 2.0 [#3360](https://github.com/sharetribe/sharetribe/pull/3360)
- Profile image is only used once it has been processed [#3427](https://github.com/sharetribe/sharetribe/pull/3427)

### Fixed

- Fix data deletion task to handle missing images [#3349](https://github.com/sharetribe/sharetribe/pull/3349)
- Requester name in waiting for confirmation messages in the inbox [#3357](https://github.com/sharetribe/sharetribe/pull/3357)
- Fixed bug in Hungarian Forint minimum transaction size [#3366](https://github.com/sharetribe/sharetribe/pull/3366)
- Stripe fee information in listing page [#3384](https://github.com/sharetribe/sharetribe/pull/3384)
- Display bug in checkbox user fields [#3385](https://github.com/sharetribe/sharetribe/pull/3385)
- Fixed a broken link when no date was selected for free "per day" and "per night" listings [#3410](https://github.com/sharetribe/sharetribe/pull/3410)
- Allow to leave dropdown option unselected if it is not mandatory [#3446](https://github.com/sharetribe/sharetribe/pull/3446)

## [7.3.1] - 2018-06-07

### Added

- Add soundcloud link support in custom landing page footer [#3300](https://github.com/sharetribe/sharetribe/pull/3300)
- Add checkbox for consent for receiving emails from admins to signup process [#3318](https://github.com/sharetribe/sharetribe/pull/3318)
- Add popup notification when giving admin rights to a new user [#3329](https://github.com/sharetribe/sharetribe/pull/3329)
- Add link to privacy policy in the signup page [#3328](https://github.com/sharetribe/sharetribe/pull/3328)
- Allow admins to disable end-user Analytics [#3319](https://github.com/sharetribe/sharetribe/pull/3319)
- Allow links in custom listing text fields [#3297](https://github.com/sharetribe/sharetribe/pull/3297)
- Add View reviews section in the admin panel [#3267](https://github.com/sharetribe/sharetribe/pull/3267)
- Add possibility to export transaction as CSV file [#3245](https://github.com/sharetribe/sharetribe/pull/3245)


### Changed

- Improve user deletion to clear personal data more thoroughly [#3325](https://github.com/sharetribe/sharetribe/pull/3325)
- Delete automatically transactions that fail with Stripe [#3326](https://github.com/sharetribe/sharetribe/pull/3326)
- Prevent an admin from deleting their account if they are the only admin in the marketplace[#3320](https://github.com/sharetribe/sharetribe/pull/3320)
- Split first name and last name from Stripe account connection form [#3317](https://github.com/sharetribe/sharetribe/pull/3317)

### Removed

- Remove feature flag for export transactions feature [#3288](https://github.com/sharetribe/sharetribe/pull/3288)

### Fixed

- Fix Dockerfile issue where bundler was trying to install binaries in root-owner directory [#3321](https://github.com/sharetribe/sharetribe/pull/3321). Thanks, Nick Meiremans.
- Fix Stripe payout scheduler [#3309](https://github.com/sharetribe/sharetribe/pull/3309)
- Fix last 4 digits of SSN passing to Stripe for US bank accounts [#3282](https://github.com/sharetribe/sharetribe/pull/3283)

### Security

- [Critical] Fix several parameter validation bugs that opened the app to SQL injection
- Update sinatra dependency [#3344](https://github.com/sharetribe/sharetribe/pull/3344)
- Update multiple dependencies
- Present form auto-complete for Stripe secret keys [#3338](https://github.com/sharetribe/sharetribe/pull/3338)

## [7.3.0] - 2018-02-23

### Added

- Per hour availability [3166](https://github.com/sharetribe/sharetribe/pull/3166)
- Support for NZ bank account with Stripe [3165](https://github.com/sharetribe/sharetribe/pull/3165)
- "View conversations" section in admin panel [3173](https://github.com/sharetribe/sharetribe/pull/3173)
- Account tokens for Stripe bank account connections [3234](https://github.com/sharetribe/sharetribe/pull/3234)

### Changed

- Made user confirmation form more secure [3170](https://github.com/sharetribe/sharetribe/pull/3170)

### Removed

- Confirmation days x after end time of the transaction [3205](https://github.com/sharetribe/sharetribe/pull/3205)

### Fixed

- Improvements to PayPal workflow (IPNs) [3176](https://github.com/sharetribe/sharetribe/pull/3176)
- Some bugs related to sending emails from admin[#3183](https://github.com/sharetribe/sharetribe/pull/3183)

## [7.2.0] - 2017-11-22

### Added

- Add rack-attack for request throttling [#3078](https://github.com/sharetribe/sharetribe/pull/3078)
- Stripe integration [#3018](https://github.com/sharetribe/sharetribe/pull/3018)
- Sending emails from admin to specified subset of users [#3058](https://github.com/sharetribe/sharetribe/pull/3058)
- Custom Scripts are now also enabled in Custom Landing Page [#3080](https://github.com/sharetribe/sharetribe/pull/3080/files)
- Allow admins to edit their Custom Outgoing Email and Sender Name [#3106](https://github.com/sharetribe/sharetribe/pull/3106)
- Allow admins to unban users [3108](https://github.com/sharetribe/sharetribe/pull/3108)
- Ability to disable Stripe and PayPal [3112](https://github.com/sharetribe/sharetribe/pull/3112)
- Allow admins to search users by name or email [3113](https://github.com/sharetribe/sharetribe/pull/3113)
- Add an unsubscribe link to invitation emails [3136](https://github.com/sharetribe/sharetribe/pull/3136)
- Add more information texts about holding funds with Stripe [3150](https://github.com/sharetribe/sharetribe/pull/3150)

### Changed

- Lowered daily limits for invitations from 50 to 10 [3134](https://github.com/sharetribe/sharetribe/pull/3134)
- Increased unsubscribe auth token validity from 1 week to 4 weeks [3138](https://github.com/sharetribe/sharetribe/pull/3138)

### Deprecated

### Removed

### Fixed

- Fixed correct use of outgoing email address, if configured, when sending manual emails to users [#3058](https://github.com/sharetribe/sharetribe/pull/3058)
- Fixed sounds of videos in Custom Landing Pages not working [#3101](https://github.com/sharetribe/sharetribe/pull/3101)
- Fixed listing image reordering when some images were deleted [#3107](https://github.com/sharetribe/sharetribe/pull/3107)
- Fixed incorrect use of name of receipt email [3127](https://github.com/sharetribe/sharetribe/pull/3127)
- Fixed many bugs related to Stripe integration
- Fixed many bugs related to code refactoring

### Security

## [7.1.0] - 2017-09-15

### Added

- Added configuration for trusted proxies [#3040](https://github.com/sharetribe/sharetribe/pull/3040)

### Changed

- Currencies can now be formatted with translations [#3043](https://github.com/sharetribe/sharetribe/pull/3043)
- Transaction status is now named Completed everywhere instead of Confirmed [#3028](https://github.com/sharetribe/sharetribe/pull/3028)
- WebTranslateIt API keys were updated [#3029](https://github.com/sharetribe/sharetribe/pull/3029)
- Force meta tags content to be HTML escaped [#3047](https://github.com/sharetribe/sharetribe/pull/3047)
- Upgrade to latest ruby 2.3.4 with latest rubygems (2.6.13+) [#3056](https://github.com/sharetribe/sharetribe/pull/3056)

### Deprecated

### Removed

### Fixed

- Fixed image deletion in Android [3023](https://github.com/sharetribe/sharetribe/pull/3023)
- Fixed changing the names of custom listing field options [3024](https://github.com/sharetribe/sharetribe/pull/3024)
- Fixed image ordering usability in Android [3034](https://github.com/sharetribe/sharetribe/pull/3034)
- Fixed not sending automatic emails to expired and deleted marketplaces [3044](https://github.com/sharetribe/sharetribe/pull/3044)
- Fixed carousel black box rendering issue [3045](https://github.com/sharetribe/sharetribe/pull/3045)
- Fixed datepicker issue with per night availability [3046](https://github.com/sharetribe/sharetribe/pull/3046)
- Fixed listing checkbox layout issue on mobile [3048](https://github.com/sharetribe/sharetribe/pull/3048)
- Fixed admin layout issue in Safari [3066](https://github.com/sharetribe/sharetribe/pull/3066)
- Fixed error message layout placement when reviewing without grade [3067](https://github.com/sharetribe/sharetribe/pull/3067)
- Fixed managing availability of rejected booking dates [3068](https://github.com/sharetribe/sharetribe/pull/3068)

### Security

## [7.0.0] - 2017-08-08

### Changed

- Updated Rails to 5.1.1 and Node to 7.8 [#2976](https://github.com/sharetribe/sharetribe/pull/2976)

## [6.4.0] - 2017-06-09

### Added

- New feature: User can reorder listing images [#2970](https://github.com/sharetribe/sharetribe/pull/2970)

### Changed

- Change instructions how to compile assets. This reduces the JavaScript bundle size drastically. [c613cac](https://github.com/sharetribe/sharetribe/commit/c613cac)

### Fixed

- Fixed transaction button styles. Styles were broken in IE Edge. [#2968](https://github.com/sharetribe/sharetribe/pull/2968)
- Fixed admin UI language change. [#2969](https://github.com/sharetribe/sharetribe/pull/2969)
- Fix old mobile browser compatibility by removing dependency to Intl api. [#2979](https://github.com/sharetribe/sharetribe/pull/2979)

### Security

- Fixed cross-community security issues [#2978](https://github.com/sharetribe/sharetribe/pull/2978)

## [6.3.0] - 2017-04-24

### Changed

- Migrate from database session store to cookie-based session store [#2935](https://github.com/sharetribe/sharetribe/pull/2935)

### Removed

- Removed default twitter handle [#2906](https://github.com/sharetribe/sharetribe/pull/2906)

### Fixed

- Fix cropped cover photo in big screens [#2895](https://github.com/sharetribe/sharetribe/pull/2895)
- Add missing padding to homepage search field in mobile view [#2895](https://github.com/sharetribe/sharetribe/pull/2895)
- Fix unwanted scrolling in listing page by removing comment text area auto focus [#2917](https://github.com/sharetribe/sharetribe/pull/2917)
- Fix faulty feature flag dependency handling [#2932](https://github.com/sharetribe/sharetribe/pull/2932)
- Fix map bug where multiple listings close to each other caused the icon cluster to disapper when zoomed closed enough [#2942](https://github.com/sharetribe/sharetribe/pull/2942)
- Fix issue [#2885](https://github.com/sharetribe/sharetribe/issues/2885): Landing page always shows Sign up button for private marketplace, even if the user is logged in [#2944](https://github.com/sharetribe/sharetribe/pull/2944)
- Fix issue with fetching correct node.js release signing keys in Dockerfile [#2964](https://github.com/sharetribe/sharetribe/pull/2964)

### Security

- Upgrade Nokogiri and rubyzip gems [#2943](https://github.com/sharetribe/sharetribe/pull/2943)

## [6.2.0] - 2017-03-09

### Added

- Add support for redis as cache store [#2786](https://github.com/sharetribe/sharetribe/pull/2786)
- Add support for using PayPal in fake mode for development purposes. [Read more](./docs/using-fakepal.md) [#2598](https://github.com/sharetribe/sharetribe/pull/2598)
- Add support for linking to member invitation page in CLP [#2859](https://github.com/sharetribe/sharetribe/pull/2859)
- New feature: Hide irrelevant search filters when a category or subcategory is selected [#2882](https://github.com/sharetribe/sharetribe/pull/2882)
- Landing page Markdown support [#2887](https://github.com/sharetribe/sharetribe/pull/2887)
- Add instructions how to configure Harmony service [#2892](https://github.com/sharetribe/sharetribe/pull/2892)
- Add support for display name [#2869](https://github.com/sharetribe/sharetribe/pull/2869)
- Add support for customizing community description and slogan color [#2898](https://github.com/sharetribe/sharetribe/pull/2898)

### Changed

- Redirect user to the page where user was before login/sign up [#2758](https://github.com/sharetribe/sharetribe/pull/2758)
- Updated NPM packages [#2762](https://github.com/sharetribe/sharetribe/pull/2762)

### Fixed

- Fixed broken transaction button styles [#2723](https://github.com/sharetribe/sharetribe/pull/2723)
- Fixed number of issues in the Order Types form [#2858](https://github.com/sharetribe/sharetribe/pull/2858)
- Fixed an issue which caused sign up to fail partially if the Facebook profile picture upload failed [#2886](https://github.com/sharetribe/sharetribe/pull/2886)

## [6.1.0] - 2016-10-31

### Changed

- Updated Node.js to the latest LTS (long term support) version 6.9 [#2655](https://github.com/sharetribe/sharetribe/pull/2665)
- Updated NPM packages [#2655](https://github.com/sharetribe/sharetribe/pull/2665)
- Update `react_on_rails` gem [#2655](https://github.com/sharetribe/sharetribe/pull/2665)
- Upgrade Facebook SDK from v2.2 to v2.8 [#2666](https://github.com/sharetribe/sharetribe/pull/2666)
- Instruct crawlers not to follow auth paths, add crawling delay for bots that support the directive [#2693](https://github.com/sharetribe/sharetribe/pull/2693)

### Fixed

- Avoid redirect to correct S3 bucket endpoint when bucket is not in `us-east-1` region [#2605](https://github.com/sharetribe/sharetribe/pull/2605)
- Added missing database indexes [#2621](https://github.com/sharetribe/sharetribe/pull/2621), [#2634](https://github.com/sharetribe/sharetribe/pull/2634), [#2670](https://github.com/sharetribe/sharetribe/pull/2670)
- Fix bug: `rake assets:precompile` fails if MySQL is not available. Issue fixed by upgrading `money-rails` gem from 1.3 to 1.4 [#2612](https://github.com/sharetribe/sharetribe/pull/2612) by [@nicolaracco](https://github.com/nicolaracco)

### Security

- Fixed insecure gem urls in Gemfile [#2635](https://github.com/sharetribe/sharetribe/pull/2635)

## [6.0.0] - 2016-09-27

### Removed

- Dropped official support for MySQL server version 5.6. Only MySQL 5.7 is officialy supported. This release contains no other changes.

## [5.12.0] - 2016-09-27

### Added

- Added date picker for "per night" listing unit type [#2481](https://github.com/sharetribe/sharetribe/pull/2481)
- SEO: Added `rel=next` and `rel=prev` links to give a hint to crawlers about the paginated content [#2505](https://github.com/sharetribe/sharetribe/pull/2505)
- Added _New layout_ admin page where marketplace admins can enable new layout designs for the whole marketplace or just for themselves to try out [#2338](https://github.com/sharetribe/sharetribe/pull/2338) and [#2469](https://github.com/sharetribe/sharetribe/pull/2469)
- Added functionality to edit Post a new listing button text [#2448](https://github.com/sharetribe/sharetribe/pull/2448)
- Sitemap [#2492](https://github.com/sharetribe/sharetribe/pull/2492), thanks Dan Moore ([@mooreds](https://github.com/mooreds)) for helping!
- Mocha test setup for new frontend architecture [#2550](https://github.com/sharetribe/sharetribe/pull/2550)

### Deprecated

- Deprecated use of MySQL server version 5.6.x [2566](https://github.com/sharetribe/sharetribe/pull/2566)

### Removed

- Removed configuration for TravisCI (CircleCI now fully in use) [#2489](https://github.com/sharetribe/sharetribe/pull/2489)

### Changed

- Updated React on Rails to 6.0.5 [#2428](https://github.com/sharetribe/sharetribe/pull/2428) and [#2472](https://github.com/sharetribe/sharetribe/pull/2472)
- Updated [React Storybook](https://github.com/kadirahq/react-storybook) to version 2.13.0 [#2528](https://github.com/sharetribe/sharetribe/pull/2528)
- Changed ActiveRecord schema format to :sql [#2531](https://github.com/sharetribe/sharetribe/pull/2531)
- Upgraded Paperclip and Delayed::Paperclip, dropped deprecated AWS SDK v1 [#2522](https://github.com/sharetribe/sharetribe/pull/2522)
- Upgraded mysql2 dependency [#2565](https://github.com/sharetribe/sharetribe/pull/2565)

### Fixed

- Correctly add https or http to links generated in `community.rb` [#2459](https://github.com/sharetribe/sharetribe/pull/2459)
- Transactions in `initiated` state showed wrong total price in the transaction page if the item quantity was more than one [#2452](https://github.com/sharetribe/sharetribe/pull/2452)
- Fix bug in infinite scroll: The current page was not taken into account [#2532](https://github.com/sharetribe/sharetribe/pull/2532)
- Fix bug: Testimonial reminders were sent even if user had disabled them [#2557](https://github.com/sharetribe/sharetribe/pull/2557)
- Fix regression: Add quantity pickers to non-payment transactions [#2568](https://github.com/sharetribe/sharetribe/pull/2568)

## [5.11.0] - 2016-08-24

### Changed

- `RAILS_ENV=production` environment added to the `rake assets:compile` command in README [#2440](https://github.com/sharetribe/sharetribe/pull/2440) by [@pcm211](https://github.com/pcm211)

### Removed

- Remove Braintree support completely [#2424](https://github.com/sharetribe/sharetribe/pull/2424), [#2435](https://github.com/sharetribe/sharetribe/pull/2435)

## [5.10.0] - 2016-08-23

### Removed

- Disable Braintree payments [#2423](https://github.com/sharetribe/sharetribe/pull/2423)

## [5.9.0] - 2016-08-18

### Added

- Add support for using CDN for dynamic assets (uploaded images, custom compiled stylesheets) when S3 is otherwise in use [#2314](https://github.com/sharetribe/sharetribe/pull/2314)
- Add possibility to choose between light and dark background image filter for hero and info sections in custom landing pages [#2310](https://github.com/sharetribe/sharetribe/pull/2310)
- Add Pinterest link support in custom landing page footer [#2356](https://github.com/sharetribe/sharetribe/pull/2356)

### Changed

- Remove the need for CSS compilation per marketplace [#2325](https://github.com/sharetribe/sharetribe/pull/2325)
- Update default colors [#2365](https://github.com/sharetribe/sharetribe/pull/2365)

### Removed

- Removed Checkout Finland payment gateway [#2408](https://github.com/sharetribe/sharetribe/pull/2408) [#2406](https://github.com/sharetribe/sharetribe/pull/2406)

### Fixed

- Security: Rails and gems updated [#2393](https://github.com/sharetribe/sharetribe/pull/2393), [#2318](https://github.com/sharetribe/sharetribe/pull/2318)
- Fix some asset links not respecting `asset_host` setting on landing pages [#2320](https://github.com/sharetribe/sharetribe/pull/2320)

- Fix JS errors in development by replacing `babel-polyfill` with `es6-shim` [#2087](https://github.com/sharetribe/sharetribe/issues/2087)

## [5.8.0] - 2016-07-15

### Added

- Add whitelabel_branding based on features [#2052](https://github.com/sharetribe/sharetribe/pull/2052)
- Onboarding topbar and wizard enabled for everyone [#2250](https://github.com/sharetribe/sharetribe/pull/2250)
- Ability to add Google Maps API key [#2172](https://github.com/sharetribe/sharetribe/pull/2172)
- Landing page. See the [documentation](https://github.com/sharetribe/sharetribe/blob/v5.8.0/docs/landing-page.md)

### Changed

- Facebook sign up/login uses API version 2.2 instead of 2.0 [#2280](https://github.com/sharetribe/sharetribe/pull/2280)
- Improved documentation [#2271](https://github.com/sharetribe/sharetribe/pull/2271)

### Fixed

- Fix some React dependency issues caused startup timing/ordering [#2046](https://github.com/sharetribe/sharetribe/pull/2046) and [#2053](https://github.com/sharetribe/sharetribe/pull/2053)
- Fix issue that caused Google Maps Geocoder to return wrong location if the listing address contained an ampersand (&) [#2075](https://github.com/sharetribe/sharetribe/pull/2075)
- Fix pluralization error for Turkish (tr-TR) [#2292](https://github.com/sharetribe/sharetribe/pull/2292)

## [5.7.1] - 2016-05-12

### Fixed

- Fix missing map icon [#2032](https://github.com/sharetribe/sharetribe/pull/2032)

### Added

- Add instructions for handling libv8 installation problems [#2023](https://github.com/sharetribe/sharetribe/pull/2023)
- Add [React Storybook](https://github.com/kadirahq/react-storybook) styleguide for React component development [#2030](https://github.com/sharetribe/sharetribe/pull/2030)

## [5.7.0] - 2016-05-11

### Added

- Add a new job queue (css_compile) for css compilations [#1815](https://github.com/sharetribe/sharetribe/pull/1815)
- Add a warning message which will be shown 15 minutes before the next scheduled maintenance [#1835](https://github.com/sharetribe/sharetribe/pull/1835)
- Expose used feature flags to Google Tag Manager [#1856](https://github.com/sharetribe/sharetribe/pull/1856)
- React on Rails development environment [#1918](https://github.com/sharetribe/sharetribe/pull/1918).
- Add ability to create a new account with username or email which is already in use in another marketplace [#1753](https://github.com/sharetribe/sharetribe/pull/1753) [#1939](https://github.com/sharetribe/sharetribe/pull/1939)
- Prevents cookies from leaking to subdomains, fixes [#1992](https://github.com/sharetribe/sharetribe/issues/1192), adds a new configuration key: `cookie_session_key` [#1966](https://github.com/sharetribe/sharetribe/pull/1996)

### Changed

- Marketplace ID is removed from the Admin Settings URL [#1839](https://github.com/sharetribe/sharetribe/pull/1839)
- The application now depends on React components, which need to be built to run Sharetribe. [Instructions here](./client/README.md). This change is related to React on Rails environment [#1918](https://github.com/sharetribe/sharetribe/pull/1918).
- Update Ruby to 2.3.1 [#2020](https://github.com/sharetribe/sharetribe/pull/2020)

### Deprecated

- Google Analytics and Kissmetrics tracking snippets are deprecated in favor of Google Tag Manager [#1857](https://github.com/sharetribe/sharetribe/pull/1857)

### Removed

- Delete duplicated memberships from the database [#1838](https://github.com/sharetribe/sharetribe/pull/1838)
- Remove ability to join other marketplaces with an existing account [#1753](https://github.com/sharetribe/sharetribe/pull/1753) [#1939](https://github.com/sharetribe/sharetribe/pull/1939)

### Fixed

- Errors from Braintree API were ignored [#1832](https://github.com/sharetribe/sharetribe/pull/1832) by [@priviterag](https://github.com/priviterag)
- Fallback language handling was broken [#1869](https://github.com/sharetribe/sharetribe/pull/1869)
- Confirmation pending page redirects to homepage if the account is already confirmed [#1976](https://github.com/sharetribe/sharetribe/pull/1976)
- Fix bug: "Resend confirmation instructions" button didn't resend the confirmation email [#1963](https://github.com/sharetribe/sharetribe/pull/1963)

### Security

- Updated Paperclip gem [#1836](https://github.com/sharetribe/sharetribe/pull/1836)
- Unauthorized users were able to upload new listing images [#1866](https://github.com/sharetribe/sharetribe/pull/1866)
- Change session expiration time from one year to one month [#1877](https://github.com/sharetribe/sharetribe/pull/1877)
- Correctly reset old password and salt [#1961](https://github.com/sharetribe/sharetribe/pull/1961)

## [5.6.0] - 2016-03-11

### Added

- Add default queue name to jobs [#1814](https://github.com/sharetribe/sharetribe/pull/1814)

### Changed

- Update Ruby to 2.2.4 [#1774](https://github.com/sharetribe/sharetribe/pull/1774)

### Fixed

- Wrong action was executed when radio buttons were clicked back and forth [#1802](https://github.com/sharetribe/sharetribe/pull/1802)

### Security

- Redirect to HTTPS (if configured) before requesting HTTP basic authentication: [#1793](https://github.com/sharetribe/sharetribe/pull/1793)

## [5.5.0] - 2016-03-02

### Changed

- Migrate legacy passwords to Devise's Bcrypt hashing [#1781](https://github.com/sharetribe/sharetribe/pull/1781)
- Add listing id to option selections table: [#1761](https://github.com/sharetribe/sharetribe/pull/1761) and [#1762](https://github.com/sharetribe/sharetribe/pull/1762)
- Support optional site-wide HTTP basic authentication: [#1766](https://github.com/sharetribe/sharetribe/pull/1766)

### Fixed

- Fixed broken FontAwesome asset path [#1756](https://github.com/sharetribe/sharetribe/pull/1756)
- Listing author wasn't able to give feedback if the transaction starter skipped the feedback [#1767](https://github.com/sharetribe/sharetribe/pull/1767)

### Security

- Update Rails to 4.2.5.2 [#1786](https://github.com/sharetribe/sharetribe/pull/1786)

## [5.4.0] - 2016-02-22

### Changed

- Update Ruby to 2.1.8 [#1750](https://github.com/sharetribe/sharetribe/pull/1750)

### Security

- Update JSON Web Token gem [#1723](https://github.com/sharetribe/sharetribe/pull/1723)

### Fixed

- Configure Delayed Job queue adapter for ActiveJob [#1749](https://github.com/sharetribe/sharetribe/pull/1749)

## [5.3.0] - 2016-02-15

### Changed

- Updated Rails to 4.2.5.1 [#1691](https://github.com/sharetribe/sharetribe/pull/1691)

## [5.2.2] - 2016-02-09

### Added

- Initial support for upcoming new search platform. [#1404](https://github.com/sharetribe/sharetribe/pull/1404)

### Changed

- Save model attributes to cache instead of model instances [#1714](https://github.com/sharetribe/sharetribe/pull/1714)

## [5.2.1] - 2016-02-03

### Changed

- Updated Rails to 4.1.14.1 [#1678](https://github.com/sharetribe/sharetribe/pull/1678)
- Always log deprecation warnings to stderr [#1693](https://github.com/sharetribe/sharetribe/pull/1693)

### Removed

- Removed environment variable `devise_allow_insecure_token_lookup`. [#1675](https://github.com/sharetribe/sharetribe/pull/1675)

### Fixed

- Fixed Mercury Editor image uploader [#1694](https://github.com/sharetribe/sharetribe/pull/1694)

### Security

- Updated Devise gem to version 3.5 [#1675](https://github.com/sharetribe/sharetribe/pull/1675)
- Updated Sprockets gem to version 2.12.4 [#1692](https://github.com/sharetribe/sharetribe/pull/1692)
- Remove HTTP end-point that let unauthorized caller to destroy images uploaded via Mercury Editor [#1695](https://github.com/sharetribe/sharetribe/pull/1695)

## [5.2.0] - 2016-01-29

### Added

- Added `secret_key_base` [#1671](https://github.com/sharetribe/sharetribe/pull/1671)
- Added pessimistic version number for all the gems in Gemfile. Now we can safely run `bundle update` to update gems with patch level updates. [#1663](https://github.com/sharetribe/sharetribe/pull/1663)
- Added a new environment variable `delayed_job_max_run_time` which controls the maximum time for a single Delayed Job job. [#1668](https://github.com/sharetribe/sharetribe/pull/1668)
- Added a new environment variable `devise_allow_insecure_token_lookup` for seamless migration from earlier versions. See [UPGRADE.md](UPGRADE.md) for more information. [#1672](https://github.com/sharetribe/sharetribe/pull/1672)

### Changed

- Upgraded jQuery from 1.8.3 to 1.11.1 [#1667](https://github.com/sharetribe/sharetribe/pull/1667)
- Updated Devise gem to version 3.1. [#1672](https://github.com/sharetribe/sharetribe/pull/1672)

### Removed

- Gemfile clean up. Removed bunch of unused gems. [#1625](https://github.com/sharetribe/sharetribe/pull/1625)
- Removed ability to downgrade to Rails 3. [#1669](https://github.com/sharetribe/sharetribe/pull/1669)

### Fixed

- Updating a listing field changes the sorting order [#1673](https://github.com/sharetribe/sharetribe/pull/1673)

### Security

- Updated Gems with known security issues [#1667](https://github.com/sharetribe/sharetribe/pull/1667) [#1676](https://github.com/sharetribe/sharetribe/pull/1676)

## [5.1.0] - 2016-01-21

### Added

- Marketplace admins can select if the custom field creates a search filter on the homepage [#1653](https://github.com/sharetribe/sharetribe/pull/1653)
- CHANGELOG, UPGRADE and RELEASE files [#1658](https://github.com/sharetribe/sharetribe/pull/1658)

## [5.0.0] - 2015-12-31

### Changed

- Rails upgraded from 3.2 to 4.0

## Older releases

For older releases, see [RELEASE_NOTES.md](https://github.com/sharetribe/sharetribe/blob/v5.0.0/RELEASE_NOTES.md).

[Unreleased]: https://github.com/sharetribe/sharetribe/compare/v7.4.0...HEAD
[7.4.0]: https://github.com/sharetribe/sharetribe/compare/v7.3.1...v7.4.0
[7.3.1]: https://github.com/sharetribe/sharetribe/compare/v7.3.0...v7.3.1
[7.3.0]: https://github.com/sharetribe/sharetribe/compare/v7.2.0...v7.3.0
[7.2.0]: https://github.com/sharetribe/sharetribe/compare/v7.1.0...v7.2.0
[7.1.0]: https://github.com/sharetribe/sharetribe/compare/v7.0.0...v7.1.0
[7.0.0]: https://github.com/sharetribe/sharetribe/compare/v6.4.0...v7.1.0
[6.4.0]: https://github.com/sharetribe/sharetribe/compare/v6.3.0...v6.4.0
[6.3.0]: https://github.com/sharetribe/sharetribe/compare/v6.2.0...v6.3.0
[6.2.0]: https://github.com/sharetribe/sharetribe/compare/v6.1.0...v6.2.0
[6.1.0]: https://github.com/sharetribe/sharetribe/compare/v6.0.0...v6.1.0
[6.0.0]: https://github.com/sharetribe/sharetribe/compare/v5.12.0...v6.0.0
[5.12.0]: https://github.com/sharetribe/sharetribe/compare/v5.11.0...v5.12.0
[5.11.0]: https://github.com/sharetribe/sharetribe/compare/v5.10.0...v5.11.0
[5.10.0]: https://github.com/sharetribe/sharetribe/compare/v5.9.0...v5.10.0
[5.9.0]: https://github.com/sharetribe/sharetribe/compare/v5.8.0...v5.9.0
[5.8.0]: https://github.com/sharetribe/sharetribe/compare/v5.7.1...v5.8.0
[5.7.1]: https://github.com/sharetribe/sharetribe/compare/v5.7.0...v5.7.1
[5.7.0]: https://github.com/sharetribe/sharetribe/compare/v5.6.0...v5.7.0
[5.6.0]: https://github.com/sharetribe/sharetribe/compare/v5.5.0...v5.6.0
[5.5.0]: https://github.com/sharetribe/sharetribe/compare/v5.4.0...v5.5.0
[5.4.0]: https://github.com/sharetribe/sharetribe/compare/v5.3.0...v5.4.0
[5.3.0]: https://github.com/sharetribe/sharetribe/compare/v5.2.2...v5.3.0
[5.2.2]: https://github.com/sharetribe/sharetribe/compare/v5.2.1...v5.2.2
[5.2.1]: https://github.com/sharetribe/sharetribe/compare/v5.2.0...v5.2.1
[5.2.0]: https://github.com/sharetribe/sharetribe/compare/v5.1.0...v5.2.0
[5.1.0]: https://github.com/sharetribe/sharetribe/compare/v5.0.0...v5.1.0
[5.0.0]: https://github.com/sharetribe/sharetribe/compare/v4.6.0...v5.0.0
