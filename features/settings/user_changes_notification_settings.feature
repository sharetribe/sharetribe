Feature: User changes notification settings
  In order to start or stop getting email notifications about various events in Sharetribe
  As a user
  I want to be able to change my notification settings

  Scenario: User changes notification settings successfully
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And I am logged in as "kassi_testperson1"
    When I follow "Settings"
    And I follow "notification_settings_link"
    And the "...somebody comments my offer or request" checkbox should be checked
    And the "...somebody sends me a message" checkbox should be checked
    And the "Send me an update email daily if there are new listings" checkbox should be checked    
    And I uncheck "...somebody comments my offer or request"
    And I choose "do_not_email_community_updates"
    And I press "Save information"
    Then I should see "Information updated"
    And the "...somebody comments my offer or request" checkbox should not be checked
    And the "Send me an update email daily if there are new listings" checkbox should not be checked  
    And the "Don't send me update emails" checkbox should be checked  
    And the "...somebody sends me a message" checkbox should be checked
  
  
  
