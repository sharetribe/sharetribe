# Testing

## Preparations

Before you run the tests for the first time you need to load the test database with the empty structure:

`rake test:prepare`

This is useful command also in reseting the test DB to empty and clean state.

## Running tests

Run all the tests suites:

* run `rspec spec`
* run `cucumber features`
* Start Rails server and open `http://localhost:3000/test/`

## Integration testing (Cucumber)

In addition to running all the spec tests with cucumber You can limit or select the tests with tags, for example exclude the tests that are marked as pending `cucumber --tags ~@pending` Or you can run single file of tests with `cucumber features/listings/user_creates_a_new_listing.feature` or even use a line number to select only a single test: `cucumber features/listings/user_edits_his_own_listing.feature:33`

Cucumber tests use Cabybara and Selenium to test the actions in actual browser window (Firefox by default).

## Rails unit testing (RSpec)

In addition to running all the spec tests with rake spec you can also run a single file with for example `rspec ./spec/helpers/locations_helper_spec.rb` or even a single tests inside a file by pointing it with the line number: `rspec ./spec/helpers/locations_helper_spec.rb:23` That makes it faster to test a single feature that you are changing. However, it's good practice to run the whole test set before sending your code for other people to use (or to develop on).

### Guard

To speed up tests, you can use guard. It watches the file system and runs tests automatically when files change:

Run `guard` and start coding. Saving a file triggers the change.
