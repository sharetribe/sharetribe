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
    Then I get the badge "active_member_bronze"
    And I should not see badge "active_member_bronze_medium_gray" 
    When I have "6" testimonials with grade "0.5"
    And I should not see badge "active_member_silver_medium"
    When I get "1" testimonial with grade "As expected"
    Then I get the badge "active_member_silver"
    When I have "9" testimonials with grade "0.5"
    And I should not see badge "active_member_gold_medium"
    When I get "1" testimonial with grade "As expected"
    Then I get the badge "active_member_gold"
    
  @badge
  @javascript
  Scenario: User views listing freak badge
    Given I should see badge "listing_freak_bronze_medium_gray"
    And I should not see badge "listing_freak_bronze_medium"
    When I have "4" item request listings
    And I create a new item request listing
    Then I get the badge "listing_freak_bronze"
    And I should not see badge "listing_freak_silver_medium"
    When I have "14" item request listings
    And I create a new item request listing
    Then I get the badge "listing_freak_silver"
    And I should not see badge "listing_freak_gold_medium"
    When I have "19" item request listings
    And I create a new item request listing
    Then I get the badge "listing_freak_gold"
  
  @badge
  @javascript
  Scenario: User views enthusiast badge
    Given I should see badge "enthusiast_bronze_medium_gray"
    And I should not see badge "enthusiast_bronze_medium"
    When I have visited Kassi on "4" different days
    And I go to the home page
    And the system processes jobs
    Then I get the badge "enthusiast_bronze"
    And I should not see badge "enthusiast_silver_medium"
    When I have visited Kassi on "29" different days
    And I go to the home page
    And the system processes jobs
    Then I get the badge "enthusiast_silver"
    And I should not see badge "enthusiast_gold_medium"
    When I have visited Kassi on "99" different days
    And I go to the home page
    And the system processes jobs
    Then I get the badge "enthusiast_gold"
    
  @badge
  @javascript
  Scenario: User views commentator badge
    Given I should see badge "commentator_bronze_medium_gray"
    And I should not see badge "commentator_bronze_medium"
    And there is favor offer with title "massage" from "kassi_testperson2"
    When I have commented that listing "2" times
    And I comment that listing
    Then I get the badge "commentator_bronze"
    And I should not see badge "commentator_silver_medium"
    When I have commented that listing "6" times
    And I comment that listing
    Then I get the badge "commentator_silver"
    And I should not see badge "commentator_silver_gold"
    When I have commented that listing "19" times
    And I comment that listing
    Then I get the badge "commentator_gold"
    
  @badge
  @javascript
  Scenario: User views jack of all trades badge
    Given I should see badge "jack_of_all_trades_medium_gray"
    And I should not see badge "jack_of_all_trades_medium"
    And I have "1" testimonial with grade "0.5" from category "item"
    And I have "1" testimonial with grade "0.5" from category "favor"
    And I have "1" testimonial with grade "0.5" from category "rideshare"
    And I have "1" testimonial with grade "0.5" from category "housing"
    And I should not see badge "jack_of_all_trades_medium"
    When I get "1" testimonial with grade "As expected"
    Then I get the badge "jack_of_all_trades"