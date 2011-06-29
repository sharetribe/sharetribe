Feature: User edits his own listing
  In order to change the content of a listing
  As the creator of the listing
  I want to be able to edit the listing

  Scenario: User edits an item request
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy,borrow"
    And I am logged in as "kassi_testperson1"
    When I follow "Hammer"
    And I follow "Edit request"
    And the "borrow" checkbox should be checked
    And the "buy" checkbox should be checked
    And the "trade" checkbox should not be checked
    And the "rent" checkbox should not be checked
    And the "listing_title" field should contain "Hammer"
    And the "description" field should contain "test"
    And the "listing_tag_list" field should contain "tools, hammers"
    And I uncheck "Buy"
    And I check "Rent"
    And I fill in "listing_title" with "Sledgehammer"
    And I fill in "listing_description" with "My description"
    And I fill in "listing_tag_list" with "hammers, sledges"
    And I press "Save request"
    Then I should see "Item request: Sledgehammer" within "h1"
    And I should see "borrowing, renting" within "#share_types_and_tags"
    And I should see "hammers, sledges" within "#share_types_and_tags"
    And I should see "Request updated successfully" within "#notifications"
  
  @javascript
  Scenario: Trying to update an item request with invalid information
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy,borrow"
    And I am logged in as "kassi_testperson1"
    When I follow "Hammer"
    And I follow "Edit request"
    And I fill in "listing_title" with ""
    And I uncheck "borrow"
    And I uncheck "buy"
    And I select "31" from "listing_valid_until_3i"
    And I select "December" from "listing_valid_until_2i"
    And I select "2012" from "listing_valid_until_1i"
    And I press "Save request"
    Then I should see "This field is required." within ".error"
    And I should see "You must check at least one of the boxes above." within ".error"
    And I should see "This date must be between current time and one year from now." within ".error"  

  @javascript
  Scenario: Trying to update somebody else's listing
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy,borrow"
    And I am logged in as "kassi_testperson2"
    When I go to the edit listing page
    Then I should see "Only listing author can edit a listing" within "#notifications"

  @javascript
  Scenario: Trying to update somebody else's listing as an admin
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy,borrow"
    And I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights
    When I follow "Hammer"
    And I follow "Edit request"
    And I fill in "listing_title" with "Sledgehammer"
    And I press "Save request"
    Then I should see "Item request: Sledgehammer" within "h1"
    And I should see "Request updated successfully" within "#notifications"
    
  @javascript
  Scenario: Trying to update somebody else's listing as an admin of the current community
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy,borrow"
    And I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "Test"
    When I follow "Hammer"
    And I follow "Edit request"
    And I fill in "listing_title" with "Sledgehammer"
    And I press "Save request"
    Then I should see "Item request: Sledgehammer" within "h1"
    And I should see "Request updated successfully" within "#notifications"