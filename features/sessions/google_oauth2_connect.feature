Feature: Google connect

  Background:
    Given provider "google_oauth2" is mocked
    Given community "test" has social network "google_oauth2" enabled

  @javascript
  Scenario: Google connect first time, without existing account in Sharetribe
    Given I am on the home page
    When I follow log in link
    And I follow "google-oauth2-login"
    Then I should see "Welcome to Sharetribe, John! There's one more step to join"
    When I check "community_membership_consent"
    When I check "admin_emails_consent"
    And I press "Join Sharetribe"
    Then I should see "Welcome to Sharetribe!"
    And I should see "John"
    And user "johnd" should have "given_name" with value "John"
    And user "johnd" should have "family_name" with value "Due"
    And user "johnd" should have email "john@ithouse.lv"
    And user "johnd" should have "google_oauth2_id" with value "123456789012345678901"
    And user "johnd" should have "image_file_size" with value "70"
    When I open user menu
    When I follow "Settings"
    And I follow "settings-tab-notifications"
    Then the "I agree to receive occasional emails from" checkbox should be checked

