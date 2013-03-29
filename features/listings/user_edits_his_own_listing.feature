Feature: User edits his own listing
  In order to change the content of a listing
  As the creator of the listing
  I want to be able to edit the listing

  @javascript
  Scenario: User edits an item request
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy"
    And I am logged in as "kassi_testperson2"
    And I follow "Hammer"
    #And I follow "Follow this listing"
    #TODO: re-enable following here and below in this scenario
    And I click ".user-menu-toggle"
    And I follow "Logout"
    And I log in as "kassi_testperson1"
    When I follow "Hammer"
    And I follow "Edit request"
    And the "listing_title" field should contain "Hammer"
    And the "description" field should contain "test"
    #And the "listing_tag_list" field should contain "tools, hammers"
    #And I select "Renting" from "listing_share_type"
    And I fill in "listing_title" with "Sledgehammer"
    And I fill in "listing_description" with "My description"
    #And I fill in "listing_tag_list" with "hammers, sledges"
    And I attach a valid image file to "listing_listing_images_attributes_0_image"
    And I press "Save request"
    And the system processes jobs
    Then I should see "Sledgehammer" within ".item-description"
    And I should see "Buying"
    And I should see "Request updated successfully" within ".flash-notifications"
    And I should see the image I just uploaded
    When I follow "Edit request"
    Then I should see the image I just uploaded
    And I follow "Remove image"
    And wait for 2 seconds
    And I press "Save request"
    Then I should not see the image I just uploaded
    And I click ".user-menu-toggle"
    When I follow "Logout"
    And I log in as "kassi_testperson2"
    Then I should see "1" within "#notifications_link"
    #When I follow "notifications_link"
    #Then I should see "has updated a request you follow"
    #When I follow "a request you follow"
    And I follow "Stop following this listing"
    And I log out
    And I log in as "kassi_testperson1"
    And I follow "Sledgehammer"
    And I follow "Edit request"
    And I press "Save request"
    And the system processes jobs
    And I click ".user-menu-toggle"
    And I follow "Logout"
    And I log in as "kassi_testperson2"
    # Then I should not see "1" within "#notifications_link"
  
  @javascript
  Scenario: Trying to update an item request with invalid information
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy"
    And I am logged in as "kassi_testperson1"
    When I follow "Hammer"
    And I follow "Edit request" within ".action-links"
    And I fill in "listing_title" with ""
    And I select "31" from "listing_valid_until_3i"
    And I select "December" from "listing_valid_until_2i"
    And I select "2014" from "listing_valid_until_1i"
    And I press "Save request"
    Then I should see "This field is required." 
    And I should see "This date must be between current time and one year from now."  

  @javascript
  Scenario: Trying to update somebody else's listing
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy"
    And I am logged in as "kassi_testperson2"
    When I go to the edit listing page
    Then I should see "Only listing author can edit a listing" within ".flash-notifications"

  @javascript
  Scenario: Trying to update somebody else's listing as an admin
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy"
    And I am logged in as "kassi_testperson2"
    And "kassi_testperson2" is superadmin
    When I follow "Hammer"
    And I follow "Edit request"
    And I fill in "listing_title" with "Sledgehammer"
    And I press "Save request"
    Then I should see "Sledgehammer" within ".item-description"
    And I should see "Buying"
    And I should see "Request updated successfully" within ".flash-notifications"
    
  @javascript
  Scenario: Trying to update somebody else's listing as an admin of the current community
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy"
    And I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "Test"
    When I follow "Hammer"
    And I follow "Edit request"
    And I fill in "listing_title" with "Sledgehammer"
    And I press "Save request"
    Then I should see "Sledgehammer" within ".item-description"
    And I should see "Buying"
    And I should see "Request updated successfully" within ".flash-notifications"