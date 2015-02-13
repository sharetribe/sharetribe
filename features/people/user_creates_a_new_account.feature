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
  Scenario: Seeing info of community's email restriction
    Then I should see "The access to Sharetribe is restricted."



