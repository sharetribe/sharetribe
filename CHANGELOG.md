# Change Log

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/) where possible.

This file follows the best practices from [keepachangelog.com](http://keepachangelog.com/).

## [Unreleased]

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

[Unreleased]: https://github.com/sharetribe/sharetribe/compare/v5.5.0...HEAD
[5.5.0]: https://github.com/sharetribe/sharetribe/compare/v5.4.0...v5.5.0
[5.4.0]: https://github.com/sharetribe/sharetribe/compare/v5.3.0...v5.4.0
[5.3.0]: https://github.com/sharetribe/sharetribe/compare/v5.2.2...v5.3.0
[5.2.2]: https://github.com/sharetribe/sharetribe/compare/v5.2.1...v5.2.2
[5.2.1]: https://github.com/sharetribe/sharetribe/compare/v5.2.0...v5.2.1
[5.2.0]: https://github.com/sharetribe/sharetribe/compare/v5.1.0...v5.2.0
[5.1.0]: https://github.com/sharetribe/sharetribe/compare/v5.0.0...v5.1.0
[5.0.0]: https://github.com/sharetribe/sharetribe/compare/v4.6.0...v5.0.0
