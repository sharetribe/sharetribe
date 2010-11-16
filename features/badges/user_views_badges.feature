Feature: User views badges
  In order to view what achievements I have accomplished in Kassi
  As a user
  I want to be able to view my badges

  @badge
  @javascript
  Scenario: User views active member badge
    Given I should see badge "active_member_bronze_medium_gray"
    And I should not see badge "active_member_bronze_medium"
    And I have "2" testimonials with grade "0.5"
    When I get "1" testimonial with grade "Worse than expected"
    Then I should not see badge "active_member_bronze_medium"
    When I get "1" testimonial with grade "As expected"
    And the system processes jobs
    Then I should see badge "active_member_bronze_medium"
    And I should not see badge "active_member_bronze_medium_gray"