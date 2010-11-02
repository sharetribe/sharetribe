Feature: User changes notification settings
  In order to start or stop getting email notifications about various events in Kassi
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
    And I uncheck "...somebody comments my offer or request"
    And I press "Save information"
    Then I should see "Information updated"
    And the "...somebody comments my offer or request" checkbox should not be checked
    And the "...somebody sends me a message" checkbox should be checked
  
  
  
