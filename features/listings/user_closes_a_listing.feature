Feature: User closes a listing
  In order to announce that a listing is now longer valid and cannot be replied
  As the author of the listing
  I want to be able to close the listing
  
  @javascript
  Scenario: User closes and opens listing successfully
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy"  
    And I am logged in as "kassi_testperson1"
    When I follow "Hammer"
    And I follow "Close listing"
    And I should see "Listing is closed" within "#listing-message-links"
    And I should see "Reopen listing" within "#listing-message-links"
    And I should not see "Edit listing" within "#listing-message-links"
    And I should not see "Close listing" within "#listing-message-links"
    And I follow "Reopen listing"
    And I press "Save listing"
    And I should see "Listing updated successfully" within ".flash-notifications"
    And I should not see "Reopen listing" within "#listing-message-links"
    And I should see "Edit listing" within "#listing-message-links"
    And I should see "Close listing" within "#listing-message-links"
  
  @javascript
  Scenario: User closes and opens listing successfully from own profile

    # This step definition is not found on purpose. It's just to disable this test for now.
    Given We haven't yet implemented listing closing/editing from profile page

    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy"  
    And I am logged in as "kassi_testperson1"
    When I click ".user-menu-toggle"
    When I follow "Profile"
    And I follow "Close listing"
    #And I should see "Listing is closed"
    And I should see "Reopen listing"
    And I should not see "Edit listing"
    And I should not see "Close listing"
    And I follow "Reopen listing"
    And I press "Save listing"
    And I should see "Listing updated successfully" within ".flash-notifications"
    And I should not see "Reopen listing" within ".action-links"
    And I should see "Edit listing" within ".action-links"
    And I should see "Close listing" within ".action-links"
    And I should not see "You cannot send a new comment because this listing is closed." within "#comments"
    And I should see "Public discussion" within "#comments"
  
  

  
