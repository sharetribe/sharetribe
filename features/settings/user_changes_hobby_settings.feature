Feature: User changes hobby settings
  In order to maintain an up to date list of my hobbies in Sharetribe
  As a user
  I want to be able to change my hobby settings

  @seeds
  Scenario: user changes hobby settings successfully
    Given there are following users:
      | kassi_testperson1 |
    And I am logged in as "kassi_testperson1"
    When I follow "Settings"
    And I follow "hobbies_settings_link"
    And I check "Travel"
    And I check "Sports"
    And I uncheck "Fashion"
    And I press "Save information"
    Then I should see "Information updated"
    And the "Travel" checkbox should be checked
    And the "Sports" checkbox should be checked
    And the "Fashion" checkbox should not be checked

  @seeds
  Scenario: user adds a new hobby
    Given there are following users:
      | kassi_testperson1 |
    And I am logged in as "kassi_testperson1"
    When I follow "Settings"
    And I follow "hobbies_settings_link"
    And I fill in "other" with "Fishing, Philately"
    And I press "Save information"
    Then I should see "Information updated"
    And the "other" field should contain "Fishing, Philately"


