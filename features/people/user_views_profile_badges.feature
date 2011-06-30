Feature: User views profile badges
  In order to view what achievements I have accomplished in Kassi
  As a user
  I want to be able to view my badges in my profile page

  @javascript
  Scenario: User has no badges
    Given there are following users:
       | person | 
       | kassi_testperson1 |
    And I am logged in as "kassi_testperson1"
    When I follow "profile"
    Then I should not see "Badges"
  
  @javascript
  Scenario: User has rookie badge
    Given there are following users:
       | person | 
       | kassi_testperson1 |
    And I am logged in as "kassi_testperson1"
    When I follow "Tell what you need!"
    And I fill in "listing_title" with "Hammer"
    And I press "Save request"
    And the system processes jobs
    And I follow "profile"
    Then I should see "Badges"
    And I should see badge with alt text "Rookie"
    And I should see "1" within "#logged_in_notifications_icon"
    When I follow "rookie_description_link"
    Then I should see "You have added an offer or a request in Kassi for the first time. Here we go!"
    When I follow "notifications_link"
    Then I should see "You have earned the badge Rookie!"
    And I should not see "1" within "#logged_in_notifications_icon"
  
  @javascript
  Scenario: User has first event badge
    Given there are following users:
       | person | 
       | kassi_testperson1 |
       | kassi_testperson2 |
    And there is item request with title "hammer" from "kassi_testperson1" and with share type "borrow"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is accepted
    And I am logged in as "kassi_testperson2"
    When I follow "Messages"
    And I follow "Sent"
    And I follow "Give feedback"
    And I follow "As expected"
    And I press "send_testimonial_button"
    And the system processes jobs
    And I follow "Logout"
    And I log in as "kassi_testperson1"
    And I follow "profile"
    Then I should see "Badges"
    And I should see badge with alt text "First event"
    And I should see "2" within "#logged_in_notifications_icon"
    When I follow "notifications_link"
    Then I should see "You have earned the badge First event!"
    And I should not see "1" within "#logged_in_notifications_icon"
  
  
  
  
