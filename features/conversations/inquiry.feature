Feature: Inquiry

  @javascript
  Scenario: Two people engage in inquiry conversation
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And community "test" has following transaction types enabled:
      | transaction_type  | en                | fi             | button  |
      | Inquiry           | Inquiry           | Tiedustelu     | Inquire |
    And community "test" has following category structure:
      | category_type  | en                | fi             |
      | main           | Free message      | Vapaa viesti   |
    And there is a listing with title "Test message" from "kassi_testperson1" with category "Free message" and with transaction type "Inquiry"
    And I am logged in as "kassi_testperson2"
    When I follow "Test message"
    Then I should not see "Contact"
    When I press "Inquire"
    And I fill in "Message" with "Test content"
    And I press "Send message"
    And I log out
    And I log in as "kassi_testperson1"
    And I follow inbox link
    Then I should see "Test message"
    And I should not see "Accept"
