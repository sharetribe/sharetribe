Feature: Admin edits landing page
  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"

  @javascript
  Scenario: Admin edits hero section
    When I go to the landing page admin page
    Then I should see "Landing Page Editor"
    And there is a current landing page in community
    When I go to the landing page section of "hero" admin page
    Then I should see "Set the Background image for the hero section"
    And I choose "Transparent"
    When I press submit
    Then I should see "Landing Page Editor"

