Feature: User accepts new terms
  In order to confirm that I have read and accept new Kassi terms and conditions
  As a user
  I want to be able to accept new terms

  @javascript
  Scenario: User accepts the terms
    Given I am not logged in
    And the terms of community "test" are changed to "KASSI_FI2.0"
    When I log in as "kassi_testperson2"
    Then I should see "Terms of use have changed"
    When I press "I accept the new terms"
    Then I should see "Welcome to Kassi"
    And I should not see "Log in"
  
  @javascript
  Scenario: User does not accept the terms
    Given I am not logged in
    And the terms of community "test" are changed to "KASSI_FI2.0"
    When I log in as "kassi_testperson2"
    Then I should see "Terms of use have changed"
    When I follow "Home"
    Then I should see "Log in"
  
  
  
  
  
  
  


