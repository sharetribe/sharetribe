Feature: User views badges
  In order to view what achievements I have accomplished in Kassi
  As a user
  I want to be able to view my badges

  @badge
  @javascript
  Scenario: User views active member badge
    Given I should see badge "active_member_bronze_medium_gray"
    And I should not see badge "active_member_bronze_medium"
    When I have "2" testimonials with grade "0.5"
    And I get testimonial with grade "0.25"
    And the system processes jobs
    Then I should not see badge "active_member_bronze_medium"
    When I get "1" testimonial with grade "0.5"
    And the system processes jobs
    Then I should see badge "active_member_bronze_medium"
    And I should not see badge "active_member_bronze_medium_gray"