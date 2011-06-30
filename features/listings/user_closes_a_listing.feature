Feature: User closes a listing
  In order to announce that a listing is now longer valid and cannot be replied
  As the author of the listing
  I want to be able to close the listing
  
  @javascript
  Scenario: User closes and opens listing successfully
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy,borrow"  
    And I am logged in as "kassi_testperson1"
    When I follow "Hammer"
    And I follow "Close request"
    Then I should see "Request closed" within "#notifications"
    And I should see "Request is closed" within "#listing_closed_status"
    And I should see "Reopen request" within "#edit_links"
    And I should not see "Edit request" within "#edit_links"
    And I should not see "Close request" within "#edit_links"
    And I should see "You cannot send a new comment because this request is closed." within "#listing_comment_form"
    And I should not see "Write a new comment:" within "#comment_form"
    And I follow "Reopen request"
    And I press "Save request"
    And I should see "Request updated successfully" within "#notifications"
    And I should not see "Reopen request" within "#edit_links"
    And I should see "Edit request" within "#edit_links"
    And I should see "Close request" within "#edit_links"
    And I should not see "You cannot send a new comment because this request is closed." within "#listing_comment_form"
    And I should see "Write a new comment:" within "#comment_form"
  
  @javascript
  Scenario: User closes and opens listing successfully from own profile
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy,borrow"  
    And I am logged in as "kassi_testperson1"
    When I follow "Profile"
    And I follow "Requests"
    And I follow "Close request"
    Then I should see "Request closed" within "#notifications"
    And I should see "Request is closed"
    And I should see "Reopen request"
    And I should not see "Edit request"
    And I should not see "Close request"
    And I follow "Reopen request"
    And I press "Save request"
    And I should see "Request updated successfully" within "#notifications"
    And I should not see "Reopen request" within "#edit_links"
    And I should see "Edit request" within "#edit_links"
    And I should see "Close request" within "#edit_links"
    And I should not see "You cannot send a new comment because this request is closed." within "#listing_comment_form"
    And I should see "Write a new comment:" within "#comment_form"
   
  @javascript
  Scenario: User closes and opens listing successfully from edit listing page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy,borrow"  
    And I am logged in as "kassi_testperson1"
    When I follow "Hammer"
    And I follow "Edit request"
    And I follow "Close request"
    Then I should see "Request closed" within "#notifications"
    And I should see "Request is closed"
    And I should see "Reopen request"
    And I should not see "Edit request"
    And I should not see "Close request"
    And I follow "Reopen request"
    And I press "Save request"
    And I should see "Request updated successfully" within "#notifications"
    And I should not see "Reopen request" within "#edit_links"
    And I should see "Edit request" within "#edit_links"
    And I should see "Close request" within "#edit_links"
    And I should not see "You cannot send a new comment because this request is closed." within "#listing_comment_form"
    And I should see "Write a new comment:" within "#comment_form" 
  
  
  

  
