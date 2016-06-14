# Change Log

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/) where possible.

This file follows the best practices from [keepachangelog.com](http://keepachangelog.com/).

## [Unreleased]

### Fixed

- Fix some React dependency issues caused startup timing/ordering [#2046](https://github.com/sharetribe/sharetribe/pull/2046) and [#2053](https://github.com/sharetribe/sharetribe/pull/2053)
- Fix issue that caused Google Maps Geocoder to return wrong location if the listing address contained an ampersand (&) [#2075](https://github.com/sharetribe/sharetribe/pull/2075)

### Added
- Add whitelabel_branding based on features [#2052](https://github.com/sharetribe/sharetribe/pull/2052)

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

[Unreleased]: https://github.com/sharetribe/sharetribe/compare/v5.7.1...HEAD
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
