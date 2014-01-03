Feature: User adds new listing with custom field
  In order to make listing information searchable/filterable
  As a real estate seller
  I want to fill in new listing information with a dropdown menu that provides me the available house type options

  Background:
    Given there is a logged in user "real_estate_seller"
    And there is a dropdown field "House type" for category "housing" with options:
      | title |
      | condo |
      | house |

  @javascript
  Scenario:
    Given I am on the new listing page
    When I select that I want to sell housing
    Then I should see dropdown field with label "House type"
    When I fill in listing form with housing information
    And I select "condo" from "House type"
    And I save the listing
    Then I should see "House type: condo"