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
    And there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with listing shape "Selling"
    And there is a listing with title "massage" from "kassi_testperson1" with category "Services" and with listing shape "Requesting"
    And there is a listing with title "Helsinki - Turku" from "kassi_testperson1" with category "Services" and with listing shape "Selling services"
    And there is a listing with title "Housing" from "kassi_testperson2" with category "Spaces" and with listing shape "Selling"
    And there is a listing with title "bike" from "kassi_testperson1" with category "Items" and with listing shape "Requesting"
    And that listing is closed
    And there is a listing with title "sewing" from "kassi_testperson1" with category "Services" and with listing shape "Selling services"
    And that listing is closed
    And I am logged in as "kassi_testperson1"
    And I should not see "Feedback average:"
    When I open user menu
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
    And there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with listing shape "Selling"
    And there is a listing with title "massage" from "kassi_testperson1" with category "Services" and with listing shape "Requesting"
    And there is a listing with title "Helsinki - Turku" from "kassi_testperson1" with category "Services" and with listing shape "Selling services"
    And there is a listing with title "Housing" from "kassi_testperson2" with category "Spaces" and with listing shape "Selling"
    And there is a listing with title "apartment" from "kassi_testperson1" with category "Spaces" and with listing shape "Requesting"
    And that listing is closed
    And I am not logged in
    And I am on the home page
    When I follow "car spare parts"
    When I follow "listing-author-link"
    Then I should see "car spare parts"
    And I should see "Helsinki - Turku"
    And I should not see "Housing"
    And I should not see "apartment"
    And I should see "massage"

  @javascript
  Scenario: Unlogged user tries to view profile page in a private community
    Given there are following users:
       | person |
       | kassi_testperson1 |
    And community "test" is private
    When I go to the profile page of "kassi_testperson1"
    Then I should see "Sign up"