# Change Log

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/) where possible.

This file follows the best practices from [keepchangelog.com](http://keepachangelog.com/).

The Change Log starts from the release 5.0.0. For older releases, see [RELEASE_NOTES.md](https://github.com/sharetribe/sharetribe/blob/v5.0.0/RELEASE_NOTES.md).

## [Unreleased]

### Added

- Added pessimistic version number for all the gems in Gemfile. Now we can safely run `bundle update` to update gems with patch level updates. [#1663](https://github.com/sharetribe/sharetribe/pull/1663)

### Removed

- Gemfile clean up. Removed bunch of unused gems. [#1625](https://github.com/sharetribe/sharetribe/pull/1625)
- Removed ability to downgrade to Rails 3. [#1669](https://github.com/sharetribe/sharetribe/pull/1669)

## [5.1.0] - 2016-01-21

### Added

- Marketplace admins can select if the custom field creates a search filter on the homepage [#1653](https://github.com/sharetribe/sharetribe/pull/1653)
- CHANGELOG, UPGRADE and RELEASE files [#1658](https://github.com/sharetribe/sharetribe/pull/1658)

## [5.0.0] - 2015-12-31

### Changed

- Rails upgraded from 3.2 to 4.0

[Unreleased]: https://github.com/sharetribe/sharetribe/compare/v5.1.0...HEAD
[5.1.0]: https://github.com/sharetribe/sharetribe/compare/v5.0.0...v5.1.0
[5.0.0]: https://github.com/sharetribe/sharetribe/compare/v4.6.0...v5.0.0
