Feature: User views profile page
  In order to find information about a user
  As a user
  I want to 

  # FIXME: when closing listing can be viewed on user profile, uncomment rest of the test
  @javascript
  Scenario: User views his own profile page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "car spare parts" from "kassi_testperson1" and with share type "sell"
    And there is favor request with title "massage" from "kassi_testperson1"
    And there is rideshare offer from "Helsinki" to "Turku" by "kassi_testperson1"
    And there is housing offer with title "Housing" from "kassi_testperson2" and with share type "sell"
    And there is item request with title "bike" from "kassi_testperson1" and with share type "rent"
    And that listing is closed
    And there is favor offer with title "sewing" from "kassi_testperson1"
    And that listing is closed
    And I am logged in as "kassi_testperson1"
    And I should not see "Feedback average:"
    When I click ".user-menu-toggle"
    When I follow "Profile"
    Then I should see "car spare parts"
    And I should see "Helsinki - Turku"
    And I should not see "Housing"
    And I should see "massage"
    And I should not see "bike"
    And I should not see "sewing"
    #And I follow "Show also closed"
    # And I should see "bike"
    # And I follow "Offers (3)"
    # And I should see "sewing"
    # And I follow "Show only open"
    # And I should not see "sewing"
  
  @javascript
  Scenario: User views somebody else's profile page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "car spare parts" from "kassi_testperson1" and with share type "sell"
    And there is favor request with title "massage" from "kassi_testperson1"
    And there is rideshare offer from "Helsinki" to "Turku" by "kassi_testperson1"
    And there is housing offer with title "Housing" from "kassi_testperson2" and with share type "sell"
    And I am not logged in
    And I am on the home page
    When I follow "car spare parts"
    And I follow "listing_author_link"
    Then I should see "car spare parts"
    And I should see "Helsinki - Turku"
    And I should not see "Housing"
    And I should see "massage"
  
  @javascript
  Scenario: User views a profile page with listings with visibility settings
     Given there are following users:
       | person | 
       | kassi_testperson1 |
       | kassi_testperson2 |
     And there is item offer with title "car spare parts" from "kassi_testperson1" and with share type "sell"
     And privacy of that listing is "private"
     And there is favor offer with title "massage" from "kassi_testperson1"
     And there is housing request with title "apartment" from "kassi_testperson1" and with share type "rent"
     And that listing is closed
     And I am on the home page
     And I should not see "car spare parts"
     When I follow "massage"
     And I follow "listing_author_link"
     And I should not see "car spare parts"
     And I should see "massage"
     And I should see "Service offer"
     When I log in as "kassi_testperson1"
     And I follow "listing_author_link"
     Then I should see "car spare parts"
     And I should see "massage"
     And I should see "Service offer"
     And I should see "apartment"
     
  @javascript
  Scenario: User views feedback in a profile page
    Given there are following users:
       | person | 
       | kassi_testperson1 |
       | kassi_testperson2 |
       | kassi_testperson3 |
    And I am logged in as "kassi_testperson1"
    When I go to the profile page of "kassi_testperson1"
    Then I should not see "Received feedback:"
    And there is item request with title "hammer" from "kassi_testperson1" and with share type "borrow"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is accepted
    And there is feedback about that event from "kassi_testperson2" with grade "0.75" and with text "Test feedback"
    And I go to the profile page of "kassi_testperson1"
    Then I should see "1 received review"
    And I should see "100%" within ".profile-testimonials"
    And I should see "Test feedback" within ".profile-testimonials"
    When there is item request with title "saw" from "kassi_testperson1" and with share type "borrow"
    And there is a message "I offer this" from "kassi_testperson3" about that listing
    And the offer is accepted
    And there is feedback about that event from "kassi_testperson3" with grade "0.25" and with text "Test feedback"
    And I go to the profile page of "kassi_testperson1"
    Then I should see "50%" within ".profile-testimonials"
    When there is item request with title "drill" from "kassi_testperson1" and with share type "borrow"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is accepted
    And there is feedback about that event from "kassi_testperson2" with grade "0.75" and with text "OK feedback"
    And I go to the profile page of "kassi_testperson1"
    Then I should see "67%" within ".profile-testimonials"
    When there is item request with title "tool" from "kassi_testperson1" and with share type "borrow"
    And there is a message "I offer this" from "kassi_testperson3" about that listing
    And the offer is accepted
    And there is feedback about that event from "kassi_testperson3" with grade "1" and with text "Excellent feedback"
    When I go to the profile page of "kassi_testperson1"
    Then I should see "75%" within ".profile-testimonials"
    And I should see "Excellent feedback" within "#profile-testimonials-list"
    And I should see "OK feedback" within "#profile-testimonials-list"
    And I should see "Test feedback" within "#profile-testimonials-list"
    And I should see "Show all reviews"
  
  
  
  
  
  
  
  
  
  
