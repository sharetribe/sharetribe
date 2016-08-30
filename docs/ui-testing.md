# UI testing

This document describes the UI testing guidelines for the Sharetribe platform.

**Note:** The current codebase still includes lots of old feature file
tests that should not be used as examples of how to test the UI. An
example of the new style can be found in the
[paypal_steps.rb](../features/step_definitions/paypal_steps.rb)
file. Currently the test is still run with Cucumber through a feature
file, but that might change in the future.

## Capybara

New UI tests use [Capybara](http://jnicklas.github.io/capybara/) and
the test flow is written in the Ruby files (_not_ feature files). This
provides tooling that is expressive and easier to debug, and avoids
unnecessary DSLs and extra files.

In
[features/support/feature_tests/](../features/support/feature_tests/)
directory, testing helpers are split into the following directories:

 - `page/`: Page specific accessors and actions, e.g. selecting an
   element, clicking on a button on a certain page.

 - `section/`: Accessors and actions for UI components that are shared
   in many pages, e.g. the Topbar.

 - `action/`: UI flows that span multiple pages, using page and
   section helpers.

All the CSS selectors should live within page or section helpers.
