Feature: User closes a listing
  In order to announce that a listing is now longer valid and cannot be replied
  As the author of the listing
  I want to be able to close the listing

  @javascript
  Scenario: User closes and opens listing successfully and select a new subcategory
    Given there are following users:
      | person |
      | kassi_testperson1 |
    And there is a listing with title "Hammer" from "kassi_testperson1" with category "Items" and with listing shape "Requesting"
    And I am logged in as "kassi_testperson1"
    When I follow "Hammer"
    And I follow "Close listing"
    And I should see "Listing is closed" within "#listing-message-links"
    And I should see "Reopen listing" within "#listing-message-links"
    And I should not see "Edit listing" within "#listing-message-links"
    And I should not see "Close listing" within "#listing-message-links"
    And I follow "Reopen listing"
    And I select subcategory "Tools"
    And I press "Post listing"
    And I should see "Listing updated successfully"
    And I should not see "Reopen listing" within "#listing-message-links"
    And I should see "Edit listing" within "#listing-message-links"
    And I should see "Close listing" within "#listing-message-links"
