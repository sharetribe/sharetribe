Feature: User pays with MangoPay after accepted transaction
  In order to pay easily for what I've bought
  As a user
  I want to pay via the platform
  
  @javascript
  Scenario: requester pays with MangoPay
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And community "test" has payments in use via Mangopay
    And "kassi_testperson2" has payout details filled
    And there is item offer with title "math book" from "kassi_testperson2" and with share type "sell" and with price "12"
    And all listings of "kassi_testperson2" are made with his first organization
    And there is a message "I want to buy" from "kassi_testperson1" about that listing
    And I am logged in as "kassi_testperson2"
    When I follow "inbox-link"
    And I should see "1" within ".inbox-toggle"
    And I follow "conversation_title_link_1"
    And I follow "Accept"
    And I fill in "conversation_message_attributes_content" with "Ok, then pay!"
    And I press "Send"
    Then I should see "Accepted"
    When I am logged in as "kassi_testperson1"
    When I follow "inbox-link"
    Then I should see "Pay"
    When I follow "Pay"
    Then I should see "New payment"
    And I should see "13.19€"
    
    When I follow "Continue to pay"
    Then I should see "YOU ARE IN A TEST ENVIRONMENT"
    And I should see "EUR13.19"
    
    And I fill in "number" with "4970101122334422"
    And I fill in "cvv" with "123"
    And I select "12" from "expirationDate_month"
    And I select "2023" from "expirationDate_year"
    And I click "#paybutton"
    
    Then I should see "Payment successful"

