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

  @javascript
  Scenario: Admin adds single column section
    When I go to the landing page admin page
    Then I should see "Landing Page Editor"
    And there is a current landing page in community
    And I select "Info 1 Column" from "section_kind"
    Then I should see "New single column section"
    And I fill in "section_id" with "test1"
    And I fill in "section_title" with "DemoSingle"
    And I fill in "section_paragraph" with "DemoSingleParagraph"
    And I press submit
    Then I should see "Landing Page Editor"
    When I follow "Preview landing page" in new window
    Then I should see "DemoSingle"
    And I should see "DemoSingleParagraph"
