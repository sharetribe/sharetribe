Feature: Real estate seller wants to fill in easy form with separated fields to remember all the required information

  Background:
    Given there is a dropdown field for "item" category with options:
      | options |
      | condo |
      | house |
    And I am logged in as "kassi_testperson"

  Scenario:
    When I add a new listing
    Then I should see dropdown field with options:
      | options |
      | condo |
      | house |
      | family car |
    When I fill in listing form
    And I select option field "condo"
    And I save the listing
    When I go to listing page
    Then then House type should be "condo"
