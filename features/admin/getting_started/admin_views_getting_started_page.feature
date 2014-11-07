Feature: User views getting started page

  @javascript
  Scenario: User views the getting started page
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"
    And I am on the getting started page for admins
    Then I should see "Welcome to your marketplace"