# Upgrade Facebook SDK version

Facebook is drooping support to its old SDK versions periodically. When ever this happens, we need to make sure we are not using an unsupported SDK. This guide shows how to upgrade Facebook SDK version.

## What changes are required

Use Facebook's [API Upgrade Tool](https://developers.facebook.com/tools/api_versioning/) to see the changes between different API versions.

## Upgrade the SDK version

Edit the file [config/facebook_sdk_version.rb](/config/facebook_sdk_version.rb). There are two configurations in that file

* `SERVER`: The current server-side SDK version
* `CLIENT`: The current client-side JavaScript SDK version

Make the version change and test that everything works.
