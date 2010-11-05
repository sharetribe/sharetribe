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
    And there is item request with title "hammer" from "kassi_testperson3" and with share type "borrow"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is accepted
    And there is feedback about that event from "kassi_testperson2" with grade "0.75" and with text "Well done"
    And there is item offer with title "saw" from "kassi_testperson3" and with share type "lend"
    And there is a message "I request this" from "kassi_testperson2" about that listing
    And the request is accepted
    And there is feedback about that event from "kassi_testperson2" with grade "0.25" and with text "You suck"
    And there is favor offer with title "massage" from "kassi_testperson2"
    And there is a message "I request this" from "kassi_testperson3" about that listing
    And the request is accepted
    And there is feedback about that event from "kassi_testperson2" with grade "0.25" and with text "You suck"
    And I am logged in as "kassi_testperson1"
    When I go to the profile page of "kassi_testperson3"
    And I follow "Show all feedback (3)"
    Then I should see "Feedback average:"
    And I should see "2.7/5" within ".feedback_average_value"
    And I should see "Well done" within ".light_green"
    And I should see "You suck" within ".light_red"
    And I should see "2" within "#feedback_grade_2"
    And I should see "1" within "#feedback_grade_4"
    And I should see "0" within "#feedback_grade_1"
    And I should see "0" within "#feedback_grade_3"
    And I should see "0" within "#feedback_grade_5"
  
  
  
  
