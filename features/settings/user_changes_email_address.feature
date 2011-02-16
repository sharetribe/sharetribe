Feature: User changes email address
  In order to change the email address associated with me in Kassi
  As a user
  I want to be able to change my email address
  
  @javascript
  Scenario: Changing email address successfully
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And I am logged in as "kassi_testperson1"
    When I follow "Settings"
    And I follow "Account"
    And I follow "account_email_link"
    And I fill in "person_email" with random email
    And I press "email_submit"
    And I follow "account_email_link"
    Then I should see "Information updated" within "#notifications"
    And I should see the email I gave within "#account_email_content"
    
    
  @javascript
  Scenario: Trying to update email address with false information
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And I am logged in as "kassi_testperson1"
    When I follow "Settings"
    And I follow "Account"
    And I follow "account_email_link"
    And I fill in "person_email" with "this is not email"
    And I press "email_submit"
    Then I should not see "Information updated" within "#notifications"
    And I should see "Please enter a valid email address." within ".error_account"
  
  
  

  
