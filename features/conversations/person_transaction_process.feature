Feature: Transaction process between two users

  @javascript
  Scenario: Monetary transaction started from an offer listing
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And community "test" has payments in use
    And "kassi_testperson1" has Checkout account
    And there is a listing with title "Hammer" from "kassi_testperson1" with category "Items" and with transaction type "Selling"
    And the price of that listing is 20.00 EUR
    And I am logged in as "kassi_testperson2"

    # Starting the conversation
    When I follow "Hammer"
    And I press "Buy this item"
    And I fill in "Message" with "I want to buy this item"
    And I press "Buy this item"
    And the system processes jobs
    And "kassi_testperson1@example.com" should receive an email
    When I follow inbox link
    Then I should see "to accept the request"
    And I log out

    # Accepting
    When I open the email
    And I follow "View message" in the email
    And I log in as "kassi_testperson1"
    Then I should see "1" within "#inbox-link"
    When I follow "Accept request"
    And I fill in "message[content]" with "Ok, that works!"
    And I press "Send"
    Then I should see "Accepted"
    And I should see "to pay"
    And I should not see "1" within "#inbox-link"
    And the system processes jobs
    And "kassi_testperson2@example.com" should receive an email
    And I log out

    # Rest of the steps are not tested because we cannot reliably access Checkout/Osuuspankki in all test environments

  @javascript
  Scenario: Free message conversation for non-monetary transaction
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "Hammer" from "kassi_testperson1" with category "Items" and with transaction type "Requesting"
    And I am logged in as "kassi_testperson2"

    # Starting the conversation
    When I follow "Hammer"
    And I press "Offer"
    And I fill in "Message" with "I can lend this item"
    And I press "Send"
    And the system processes jobs
    And "kassi_testperson1@example.com" should receive an email
    And I log out

    # Replying
    When I open the email
    And I follow "View message" in the email
    And I log in as "kassi_testperson1"
    And I fill in "message[content]" with "Ok, that works!"
    And I press "Send reply"
    Then I should see "Please wait..."
    And I should see "Send reply"
    When the system processes jobs
    Then "kassi_testperson2@example.com" should receive an email
    And I log out
