@javascript
Feature: User creates a new account
  In order to log in to Sharetribe
  As a person who does not have an account in Sharetribe
  I want to create a new account in Sharetribe

  Background:
    Given I am not logged in
    And I am on the signup page

  Scenario: Creating a new account successfully
    Then I should not see "The access to Sharetribe is restricted."
    When I fill in "person[username]" with random username
    And I fill in "First name" with "Testmanno"
    And I fill in "Last name" with "Namez"
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with random email
    And I check "person_terms"
    And I check "person_admin_emails_consent"
    And I press "Create account"
    Then I should see "Please confirm your email"
    When wait for 1 seconds
    Then I should receive 1 email
    When I open the email
    And I click the first link in the email
    Then I should have 2 emails
    And I should see "The email you entered is now confirmed"
    And I should not see my username
    And Most recently created user should be member of "test" community with its latest consent accepted
    When I open user menu
    When I follow "Settings"
    And I follow "settings-tab-notifications"
    Then the "I accept to receive occasional emails from" checkbox should be checked

  Scenario: Creating a new account successfully without giving admin email consent
    Then I should not see "The access to Sharetribe is restricted."
    When I fill in "person[username]" with random username
    And I fill in "First name" with "Testmanno"
    And I fill in "Last name" with "Namez"
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with random email
    And I check "person_terms"
    And I press "Create account"
    Then I should see "Please confirm your email"
    When wait for 1 seconds
    Then I should receive 1 email
    When I open the email
    And I click the first link in the email
    Then I should have 2 emails
    And I should see "The email you entered is now confirmed"
    And I should not see my username
    And Most recently created user should be member of "test" community with its latest consent accepted
    When I open user menu
    When I follow "Settings"
    And I follow "settings-tab-notifications"
    Then the "I accept to receive occasional emails from" checkbox should not be checked

  Scenario: Trying to create account with unavailable username
    When I fill in "person[username]" with "kassi_testperson2"
    And I fill in "First name" with "Testmanno"
    And I fill in "Last name" with "Namez"
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with random email
    And I press "Create account"
    Then I should see "This username is already in use."

  Scenario: Trying to create account with invalid username
    When I fill in "person[username]" with "sirkka-liisa"
    And I fill in "First name" with "Testmanno"
    And I fill in "Last name" with "Namez"
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with random email
    And I press "Create account"
    Then I should see "Username is invalid."

  Scenario: Trying to create account with unavailable email
    When I fill in "person[username]" with random username
    And I fill in "First name" with "Testmanno"
    And I fill in "Last name" with "Namez"
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with "kassi_testperson2@example.com"
    And I press "Create account"
    Then I should see "The email you gave is already in use."

  Scenario: Trying to create an account without First name and last name
    When I fill in "person[username]" with random username
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with random email
    And I check "person_terms"
    And I press "Create account"
    Then I should see "This field is required."
    When given name and last name are not required in community "test"
    And I am on the signup page
    When I fill in "person[username]" with random username
    And I fill in "person[username]" with random username
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with random email
    And I check "person_terms"
    And I press "Create account"
    And wait for 1 seconds
    Then I should receive 1 email
    When I open the email
    And I click the first link in the email
    And wait for 1 seconds
    Then I should have 2 emails
    And I should see "The email you entered is now confirmed"

  @subdomain2
  Scenario: Trying to create an account with email and username that exist in another marketplace
    Given feature flag "new_login" is enabled
    When I fill in "person[username]" with "kassi_testperson1"
    And I fill in "First name" with "Testmanno"
    And I fill in "Last name" with "Namez"
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with "kassi_testperson3@example.com"
    And I check "person_terms"
    And I press "Create account"
    And wait for 1 seconds
    Then "kassi_testperson3@example.com" should receive 1 email
    When I open the email
    And I click the first link in the email
    And wait for 1 seconds
    Then "kassi_testperson3@example.com" should have 2 emails
    And I should see "The email you entered is now confirmed"

  @subdomain2
  Scenario: Trying to create an account in an invitation-only marketplace with email and username that exist in another marketplace
    Given there are following users:
      | person |
      | kassi_testperson3 |
    And community "test2" requires invite to join
    And I refresh the page
    And there is an invitation for community "test2" with code "GH1JX8"
    And feature flag "new_login" is enabled
    Then I should see "The access to Sharetribe is restricted."
    When I fill in "Invitation code" with "GH1JX8"
    And I fill in "person[username]" with "kassi_testperson1"
    And I fill in "First name" with "Testmanno"
    And I fill in "Last name" with "Namez"
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with "kassi_testperson3@example.com"
    And I check "person_terms"
    And I press "Create account"
    And wait for 1 seconds
    Then "kassi_testperson3@example.com" should receive 1 email
    When I open the email
    And I click the first link in the email
    And wait for 1 seconds
    Then "kassi_testperson3@example.com" should have 2 emails
    And I should see "The email you entered is now confirmed"

  Scenario: Creating a new account with custom fields successfully
    And there is a required person custom text field "House type" in community "test"
    And there is a required person custom numeric field "Points" in community "test"
    And there is a required person custom date field "Member since" in community "test"
    And there is a required person custom dropdown field "Balcony type" in community "test" with options:
      | en             | fi                   |
      | No balcony     | Ei parveketta        |
      | French balcony | Ranskalainen parveke |
      | Backyard       | Takapiha             |
    And there is a required person custom checkbox field "Language" in community "test" with options:
      | en             | fi                   |
      | English language | englanti           |
      | German language  | saksa              |
      | French language  | ranskalainen       |
    And I am on the signup page
    Then I should not see "The access to Sharetribe is restricted."
    When I fill in "person[username]" with random username
    And I fill in "First name" with "Testmanno"
    And I fill in "Last name" with "Namez"
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with random email
    And I check "person_terms"
    And I check "person_admin_emails_consent"
    And I fill in "person_custom_fields_0" with "Log Cabin"
    And I fill in "person_custom_fields_1" with "23"
    And I select "2000" from "person[custom_field_values_attributes][][date_value(1i)]"
    And I select "June" from "person[custom_field_values_attributes][][date_value(2i)]"
    And I select "21" from "person[custom_field_values_attributes][][date_value(3i)]"
    And I select "French balcony" from "person_custom_fields_3"
    And I check "English language"
    And I check "French language"
    And I press "Create account"
    Then I should see "Please confirm your email"
    When wait for 1 seconds
    Then I should receive 1 email
    When I open the email
    And I click the first link in the email
    Then I should have 2 emails
    And I should see "The email you entered is now confirmed"
    And I should not see my username
    And Most recently created user should be member of "test" community with its latest consent accepted
    When I open user menu
    When I follow "Settings"
    Then the "person_custom_fields_0" field should contain "Log Cabin"
    And the "person_custom_fields_1" field should contain "23"
    And the "person[custom_field_values_attributes][][date_value(1i)]" field should contain "2000"
    And the "person[custom_field_values_attributes][][date_value(2i)]" field should contain "6"
    And the "person[custom_field_values_attributes][][date_value(3i)]" field should contain "21"
    And I should see "French balcony"
    And the "English language" checkbox should be checked
    And the "German language" checkbox should not be checked
    And the "French language" checkbox should be checked

  Scenario: Creating a new account successfully with spaces before and after email
    Then I should not see "The access to Sharetribe is restricted."
    When I fill in "person[username]" with random username
    And I fill in "First name" with "Testmanno"
    And I fill in "Last name" with "Namez"
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with " phyllis@example.com    "
    And I check "person_terms"
    And I check "person_admin_emails_consent"
    And I press "Create account"
    Then I should see "Please confirm your email"

