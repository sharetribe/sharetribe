@only_without_asi
Feature: Facebook connect
  In order to connect to Sharetribe with existing Facebook account
  As a user
  I want to do Facebook connect to link the accounts
  
  @javascript
  Scenario: Facebook connect first time, with same email in Sharetribe DB
    Given there are following users:
      | person     | given_name | email | 
      | facebooker | Mircos     | markus@example.com |
    Then user "facebooker" should have "image_file_size" with value "nil"
    Given I am on the home page
    When I click ".login-menu-toggle"
    And I follow "Log in with your Facebook account"
    Then I should see "Successfully authorized from Facebook account"
    And I should see "Mircos"
    And user "facebooker" should not have "image_file_size" with value "nil"
  
  @fix_for_new_design
  Scenario: Facebook connect with different email in Sharetribe DB
    Given there are following users:
      | person | given_name |
      | facebooker | Marcos |
    Then user "facebooker" should have "image_file_size" with value "nil"
    Given I am on the home page
    When I click ".login-menu-toggle"
    And I follow "Log in with your Facebook account"
    Then I should see "Connect your Facebook account"
    When I fill in "person_login" with "facebooker"
    And I fill in "person_password" with "testi"
    And I press "Log in" 
    Then I should see "Welcome to Sharetribe"
    And I should see "Marcos"
    And user "facebooker" should have "facebook_id" with value "597013691"
    And user "facebooker" should not have "image_file_size" with value "nil"
  
  @fix_for_new_design
  Scenario: Facebook connect first time, without existing account in Sharetribe
    Given I am on the home page
    When I click ".login-menu-toggle"
    And I follow "Log in with your Facebook account"
    Then I should see "Connect your Facebook account"
    And I should see "Markus Sugarberg"
    When I follow "click here"
    Then I should see "Join community 'Test'"
    When I check "community_membership_consent"
    And I press "Join community"
    Then I should see "successfully joined this community"
    And I should see "Markus"
    And user "markus_sharer_123" should have "given_name" with value "Markus"
    And user "markus_sharer_123" should have "family_name" with value "Sugarberg"
    And user "markus_sharer_123" should have "email" with value "markus@example.com"
    And user "markus_sharer_123" should have "facebook_id" with value "597013691"
    And user "markus_sharer_123" should not have "image_file_size" with value "nil"
  
  Scenario: Facebook connect to log in when the accounts are already linked
    Given there are following users:
      | person | facebook_id | given_name |
      | marko | 597013691 | Marko |
    Given I am on the home page
    When I click ".login-menu-toggle"
    And I follow "Log in with your Facebook account"
    Then I should see "Successfully authorized from Facebook account"
    And I should see "Marko"
  
  @fix_for_new_design
  Scenario: User connects to FB but cancels the linking
    Given I am on the home page
    When I click ".login-menu-toggle"
    And I follow "Log in with your Facebook account"
    Then I should see "Connect your Facebook account"
    And I should see "Markus Sugarberg"
    When I follow "cancel"
    Then I should not see "Markus"
    When I follow "Log in"
    Then I should not see "Connect your Facebook account"
    And I should not see "Sugarberg"
    And I should see "Log in to Sharetribe"
    
  Scenario: The facebook login doesn't succeed
    Given I am on the home page
    And there will be and error in my Facebook login
    When I click ".login-menu-toggle"
    And I follow "Log in with your Facebook account"
    Then I should see "Could not authorize you from Facebook"
  
  

  
  
  

  
  
  
  
  
  
  
