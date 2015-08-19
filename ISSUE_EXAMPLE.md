
##### Sharetribe Version:

82cbcc5c1405790e5c1c5bb02731a452503dd074

##### Environment:

Mac OS X 10.10.3

##### Server mode:

Development

##### Description:

Test suite fails when running them with Zeus for the first time.

##### Steps To Reproduce:

1. Make sure Zeus is not running
1. `zeus start` (wait until all environment have started)
1. `zeus rspec spec/`

##### Expected Result:

All tests pass.

##### Actual Result:

2 tests fail due to "Email in invalid error"

The failing tests are:

```
./spec/controllers/admin/communities_controller_spec.rb:12 # Admin::CommunitiesController#update_integrations should allow changing twitter_handle
./spec/controllers/admin/communities_controller_spec.rb:16 # Admin::CommunitiesController#update_integrations should not allow changes to a different community
```

##### Debugging information

```
Failures:

  1) Admin::CommunitiesController#update_integrations should allow changing twitter_handle
     Failure/Error: sign_in_for_spec(create_admin_for(@community))
     ActiveRecord::RecordInvalid:
       Validation failed: Emails is invalid
     # ./spec/controllers/admin/communities_controller_spec.rb:8:in `block (2 levels) in <top (required)>'
     # -e:1:in `<main>'

  2) Admin::CommunitiesController#update_integrations should not allow changes to a different community
     Failure/Error: sign_in_for_spec(create_admin_for(@community))
     ActiveRecord::RecordInvalid:
       Validation failed: Emails is invalid
     # ./spec/controllers/admin/communities_controller_spec.rb:8:in `block (2 levels) in <top (required)>'
     # -e:1:in `<main>'
```
