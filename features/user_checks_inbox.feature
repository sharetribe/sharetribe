Feature: User checks inbox
  In order to check my unread messages
  As a user
  I want to be able to go to my inbox and see my messages
  
  Scenario: Viewing new conversations
    Given a new favor request with title "Massage"
    And a new message "Test" from "kassi_testperson2" about favor request
    And I am logged in
    When I follow "Messages"
    Then I should see "Messages" within "h1"
    And I should see "Favor offer: Massage" within "h4"
  
  
  

  
