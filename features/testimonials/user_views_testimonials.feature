Feature: User views testimonials
  In order to find out whether a user is trustworthy
  As a person who is considering offering something to or requesting something from that user
  I want to be able to view feedback the user has received
  
  @javascript
  Scenario: User views testimonials successfully
    Given there are following users:
       | person | 
       | kassi_testperson1 |
       | kassi_testperson2 |
       | kassi_testperson3 |
    And there is a listing with title "hammer" from "kassi_testperson3" with category "Items" and with transaction type "Requesting"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is accepted
    And there is feedback about that event from "kassi_testperson2" with grade "0.75" and with text "Well done"
    When I go to the testimonials page of "kassi_testperson3"
    When there is a listing with title "saw" from "kassi_testperson3" with category "Items" and with transaction type "Lending"
    And there is a message "I request this" from "kassi_testperson2" about that listing
    And the request is accepted
    And there is feedback about that event from "kassi_testperson2" with grade "0.25" and with text "You suck"
    And I go to the testimonials page of "kassi_testperson3"
    When there is a listing with title "massage" from "kassi_testperson2" with category "Services" and with transaction type "Selling services"
    And there is a message "I request this" from "kassi_testperson3" about that listing
    And the request is accepted
    And there is feedback about that event from "kassi_testperson2" with grade "0.5" and with text "You suck"
    And I am logged in as "kassi_testperson1"
    And I go to the testimonials page of "kassi_testperson3"
    Then I should see "received review"
    And I should see "67%" within "#people-testimonials"
    And I should see "Well done"
    And I should see "You suck" within ".light_red"
  
  
  
  
