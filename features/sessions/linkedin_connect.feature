Feature: LinkedIn connect

  Background:
    Given provider "linkedin" is mocked
    Given community "test" has social network "linkedin" enabled

  @javascript
  Scenario: Google connect first time, without existing account in Sharetribe
    Given I am on the home page
    When I follow log in link
    And I follow "linkedin-login"
    Then I should see "Welcome to Sharetribe, Tony! There's one more step to join"
    When I check "community_membership_consent"
    When I check "admin_emails_consent"
    And I press "Join Sharetribe"
    Then I should see "Welcome to Sharetribe!"
    And I should see "Tony"
    And user "tonyt" should have "given_name" with value "Tony"
    And user "tonyt" should have "family_name" with value "Testmen"
    And user "tonyt" should have email "devel@example.com"
    And user "tonyt" should have "linkedin_id" with value "50k-SSSS99"
    And user "tonyt" should have "image_file_size" with value "70"
    When I open user menu
    When I follow "Settings"
    And I follow "settings-tab-notifications"
    Then the "I agree to receive occasional emails from" checkbox should be checked

