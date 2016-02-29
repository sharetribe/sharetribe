# How Sharetribe applies Semantic versioning

[Semantic Versioning](http://semver.org/) is a great versioning schema especially for libraries and other software that define a clear *public API*. However, for a full-blown application such as Sharetribe, it may not be obvious what the *public API* is.

This document is meant to clarify what we think is the *public API* and how we update the version number.

## Public API

**Hosting environment**

Major changes to the hosting environment increment major version number.

*Example:* Require a new database before updating.

If the platform admin needs to do some minor changes to the hosting environment, we will document these steps in [UPGRADE.md](UPGRADE.md). Depending on the size of the change, we may increment the major version number or minor version number.

*Example of a minor change to hosting environment:* Need to set a new configuration value or environment variable value.

If the upgrade requires actions from the platform admin that are difficult to do and/or undo, we will increment the major version number.

*Example:* The upgrade contains a database migration that deletes a lot of data and can't be rollbed back.
