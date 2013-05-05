Feature: User views profile badges
  In order to view what achievements I have accomplished in Sharetribe
  As a user
  I want to be able to view my badges in my profile page

  @javascript
  Scenario: User has no badges
    Given there are following users:
       | person | 
       | kassi_testperson1 |
    And I am logged in as "kassi_testperson1"
    When I click ".user-menu-toggle"
    When I follow "Profile"
    Then I should not see "Badges"

  @javascript
  Scenario: User has rookie badge
    Given there are following users:
       | person | 
       | kassi_testperson1 |
    And I am logged in as "kassi_testperson1"
    When I follow "Post a new listing!"
    And I follow "need something"
    And I follow "An item"
    And I follow "Tools"
    And I follow "borrow it"
    And I fill in "listing_title" with "Hammer"
    And I press "Save listing"
    And the system processes jobs
    When I click ".user-menu-toggle"
    And I follow "Profile"
    Then I should see "1 badge"
    And I should see badge with alt text "Rookie"
    And I should see "1" within ".notifications-toggle"
    When I follow "rookie_description_link"
    Then I should see "You have added an offer or a request in Sharetribe for the first time. Here we go!"
    When I follow "notifications_link"
    Then I should see "You have earned the badge Rookie!"
    And I should not see "1" within ".notifications-toggle"
  
  @javascript
  Scenario: User has first event badge
    Given there are following users:
       | person | 
       | kassi_testperson1 |
       | kassi_testperson2 |
    And there is item request with title "hammer" from "kassi_testperson1" and with share type "borrow"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is confirmed
    And I am logged in as "kassi_testperson2"
    When I follow "inbox-link"
    And I follow "Give feedback"
    And I click "#positive-grade-link"
    And I fill in "How did things go?" with "Everything went ok."
    And I press "send_testimonial_button"
    And the system processes jobs
    When I click ".user-menu-toggle"
    And I follow "Logout"
    And I log in as "kassi_testperson1"
    When I click ".user-menu-toggle"
    And I follow "Profile"
    Then I should see "1 badge"
    And I should see badge with alt text "First event" within ".badge-list"
    And I should see "2" within ".notifications-toggle"
    When I follow "notifications_link"
    Then I should see "You have earned the badge First event!"
    And I should not see "1" within ".notifications-toggle"
  
  
  
  
