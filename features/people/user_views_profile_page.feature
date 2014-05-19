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
    And there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with transaction type "Selling"
    And there is a listing with title "massage" from "kassi_testperson1" with category "Services" and with transaction type "Requesting"
    And there is a listing with title "Helsinki - Turku" from "kassi_testperson1" with category "Services" and with transaction type "Selling services"
    And there is a listing with title "Housing" from "kassi_testperson2" with category "Spaces" and with transaction type "Selling"
    And there is a listing with title "bike" from "kassi_testperson1" with category "Items" and with transaction type "Requesting"
    And that listing is closed
    And there is a listing with title "sewing" from "kassi_testperson1" with category "Services" and with transaction type "Selling services"
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
    And there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with transaction type "Selling"
    And there is a listing with title "massage" from "kassi_testperson1" with category "Services" and with transaction type "Requesting"
    And there is a listing with title "Helsinki - Turku" from "kassi_testperson1" with category "Services" and with transaction type "Selling services"
    And there is a listing with title "Housing" from "kassi_testperson2" with category "Spaces" and with transaction type "Selling"
    And there is a listing with title "apartment" from "kassi_testperson1" with category "Spaces" and with transaction type "Requesting"
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
  Scenario: User views a profile page with listings with visibility settings
     Given there are following users:
       | person |
       | kassi_testperson1 |
       | kassi_testperson2 |
     And there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with transaction type "Selling"
     And privacy of that listing is "private"
     And there is a listing with title "massage" from "kassi_testperson1" with category "Services" and with transaction type "Selling services"
     And there is a listing with title "apartment" from "kassi_testperson1" with category "Spaces" and with transaction type "Requesting"
     And that listing is closed
     And I am on the home page
     And I should not see "car spare parts"
     When I follow "massage"
     And I follow "listing-author-link"
     And I should not see "car spare parts"
     And I should see "massage"
     When I log in as "kassi_testperson1"
     And I follow "listing-author-link"
     Then I should see "car spare parts"
     And I should see "massage"
     And I should not see "apartment"
     When I follow "Show also closed"
     Then I should see "apartment"

  @javascript
  Scenario: User views feedback in a profile page
    Given there are following users:
       | person |
       | kassi_testperson1 |
       | kassi_testperson2 |
       | kassi_testperson3 |
    And the community has payments in use via BraintreePaymentGateway
    And I am logged in as "kassi_testperson1"

    When I go to the profile page of "kassi_testperson1"
    Then I should not see "Received feedback:"
    And there is a listing with title "hammer" from "kassi_testperson1" with category "Items" and with transaction type "Selling"
    And the price of that listing is 20.00 USD
    And there is a pending request "I offer this" from "kassi_testperson2" about that listing
    And the request is accepted
    And there is feedback about that event from "kassi_testperson2" with grade "0.75" and with text "Test feedback"
    And I go to the profile page of "kassi_testperson1"
    Then I should see "1 received review"
    And I should see "100%" within "#people-testimonials"
    And I should see "Test feedback" within "#people-testimonials"

    When there is a listing with title "saw" from "kassi_testperson1" with category "Items" and with transaction type "Selling"
    And the price of that listing is 20.00 USD
    And there is a pending request "I offer this" from "kassi_testperson3" about that listing
    And the price of that listing is 20.00 USD
    And the request is accepted
    And there is feedback about that event from "kassi_testperson3" with grade "0.25" and with text "Test feedback"
    And I go to the profile page of "kassi_testperson1"
    Then I should see "50%" within "#people-testimonials"

    When there is a listing with title "drill" from "kassi_testperson1" with category "Items" and with transaction type "Selling"
    And the price of that listing is 20.00 USD
    And there is a pending request "I offer this" from "kassi_testperson2" about that listing
    And the request is accepted
    And there is feedback about that event from "kassi_testperson2" with grade "0.75" and with text "OK feedback"
    And I go to the profile page of "kassi_testperson1"
    Then I should see "67%" within "#people-testimonials"

    When there is a listing with title "tool" from "kassi_testperson1" with category "Items" and with transaction type "Selling"
    And the price of that listing is 20.00 USD
    And there is a pending request "I offer this" from "kassi_testperson3" about that listing
    And the request is accepted
    And there is feedback about that event from "kassi_testperson3" with grade "1" and with text "Excellent feedback"

    When I go to the profile page of "kassi_testperson1"
    Then I should see "75%" within "#people-testimonials"
    And I should see "Excellent feedback" within "#profile-testimonials-list"
    And I should see "OK feedback" within "#profile-testimonials-list"
    And I should see "Test feedback" within "#profile-testimonials-list"
    And I should see "Show all reviews"

  @javascript
  Scenario: Unlogged user tries to view profile page in a private community
    Given there are following users:
       | person |
       | kassi_testperson1 |
    And community "test" is private
    When I go to the profile page of "kassi_testperson1"
    Then I should see "Sign up"