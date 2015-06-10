Feature: Inquiry

  @javascript
  Scenario: Two people engage in inquiry conversation
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And community "test" has following listing shapes enabled:
      | listing_shape  | en                | fi             | button  |
      | Inquiry           | Inquiry           | Tiedustelu     | Inquire |
    And community "test" has following category structure:
      | category_type  | en                | fi             |
      | main           | Free message      | Vapaa viesti   |
    And there is a listing with title "Test message" from "kassi_testperson1" with category "Free message" and with listing shape "Inquiry"
    And I am logged in as "kassi_testperson2"
    When I follow "Test message"
    Then I should see "Contact"
    When I press "Inquire"
    And I fill in "message" with "Test content"
    And I press "Send message"
    And I log out
    And I log in as "kassi_testperson1"
    And I follow inbox link
    Then I should see "Test message"
    And I should not see "Accept"
