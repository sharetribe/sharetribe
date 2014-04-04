@javascript
Feature: Admin edits community look and feel

  Background:
  Given I am logged in as "kassi_testperson1"
  And "kassi_testperson1" has admin rights in community "test"
  And I am on the look and feel admin view of community "test"

  Scenario: Admin changes main color
    Then I should see that to background color of Post a new listing button is "00A26C"
    And I set the main color to "FF0099"
    And I press submit
    Then I should see that to background color of Post a new listing button is "FF0099"
