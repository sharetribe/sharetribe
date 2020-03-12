Feature: Admin edits landing page
  Background:
    # Given external plan service in use
    Given community "test" has feature "landing_page" in the plan
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"

  @javascript
  Scenario: Admin edits hero section
    # does not work under CircleCI
    Given skip this scenario
    When I go to the landing page admin page
    Then I should see "Landing page editor"
    And there is a current landing page in community
    When I go to the landing page section of "hero" admin page
    Then I should see "Set the background image for the Hero section."
    And I choose "Transparent"
    When I press submit
    Then I should see "Landing page editor"
    Given external plan service is not used

  @javascript
  Scenario: Admin adds single column section
    # does not work under CircleCI
    Given skip this scenario
    When I go to the landing page admin page
    Then I should see "Landing page editor"
    And there is a current landing page in community
    And I select "Info - One column" from "section_kind"
    Then I should see "New 'Info - One colum' section addition"
    And I fill in "section_id" with "test1"
    And I fill in "section_title" with "DemoSingle"
    And I fill in "section_paragraph" with "DemoSingleParagraph"
    And I press submit
    Then I should see "Landing page editor"
    When I follow "Preview landing page" in new window
    Then I should see "DemoSingle"
    And I should see "DemoSingleParagraph"
    Given external plan service is not used

