# How to customize your marketplace?

Before reading, should have your marketplace up and running and your should be able to access it via browser. If not, see the [installation instructions](../README.md).

There are a few settings you have to change to enable all customizations options. You can change these settings directly to database, or use Rails console.

## Make yourself a super admin

There are two admin roles in Sharetribe: Marketplace admin (defined in `CommunityMembership.admin`) and Super admin (`Person.is_admin`).

Make yourself a super admin by setting your `Person.is_admin` to `true`. This will allow you to administrate all the marketplaces. It also enables some features that are not enabled to marketplace admins such as Admin > Braintree Payment API keys

## Enable all customization options

* Plan level (`Community.plan_level`): Change the plan\_level value to number 4. This will enable Admin > Integrations (Facebook, Twitter, Google Analytics e.g) and allow you to add custom CSS/JavaScript to the page head.
* Categories (`Community.category_change_allowed`): Change to `true`. This will enable Admin > Listing categories.
* Custom listing fields (`Community.custom_fields_allowed`): Change to `true`. This will enable Admin > Listing fields.
* Privacy policy (`Community.privacy_policy_change_allowed`): Change to `true`. This will enable editing content of About > Privacy page
* Terms: (`Community.terms_change_allowed`): Change to `true`. This will enable editing content of About > Terms of use page
* Logo (`Community.logo_change_allowed`): Change to `true`. This will enable logo change in Admin > Community look and feel