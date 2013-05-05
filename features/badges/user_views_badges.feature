Feature: User views badges
  In order to view what achievements I have accomplished in Sharetribe
  As a user
  I want to be able to view my badges
    
  @badge
  @javascript
  Scenario: User views active member badge
    Given I should not see badge "active_member_bronze_medium"
    And I have "2" testimonials with grade "1"
    When I get "1" testimonial with grade "negative"
    Then I should not see badge "active_member_bronze_medium"
    When I get "1" testimonial with grade "positive"
    Then I get the badge "active_member_bronze"
    And I should not see badge "active_member_bronze_medium_gray" 
    When I have "6" testimonials with grade "1"
    And I should not see badge "active_member_silver_medium"
    When I get "1" testimonial with grade "positive"
    Then I get the badge "active_member_silver"
    When I have "14" testimonials with grade "1"
    And I should not see badge "active_member_gold_medium"
    When I get "1" testimonial with grade "positive"
    Then I get the badge "active_member_gold"
    
  @badge
  @javascript
  Scenario: User views listing freak badge
    Given I should not see badge "listing_freak_bronze_medium"
    When I have "4" favor request listings
    And I create a new item request listing
    Then I get the badge "listing_freak_bronze"
    And I should not see badge "listing_freak_silver_medium"
    When I have "14" favor request listings
    And I create a new item request listing
    Then I get the badge "listing_freak_silver"
    And I should not see badge "listing_freak_gold_medium"
    When I have "19" favor request listings with share type "buy"
    And I create a new item request listing
    Then I get the badge "listing_freak_gold"
    
  @badge
  @javascript
  Scenario: User views commentator badge
    Given I should not see badge "commentator_bronze_medium"
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
    Given I should not see badge "jack_of_all_trades_medium"
    And I have "1" testimonial with grade "1" from category "item"
    And I have "1" testimonial with grade "1" from category "favor"
    And I have "1" testimonial with grade "1" from category "rideshare"
    And I have "1" testimonial with grade "1" from category "housing"
    And I should not see badge "jack_of_all_trades_medium"
    When I get "1" testimonial with grade "positive"
    Then I get the badge "jack_of_all_trades"
  
  @badge
  @javascript
  Scenario: User views chauffer badge
    Given I should not see badge "chauffer_bronze_medium"
    And I have "1" testimonial with grade "1" from category "rideshare" as "offerer"
    And I should not see badge "chauffer_bronze_medium"
    When I get "1" testimonial with grade "positive" from category "rideshare"
    Then I get the badge "chauffer_bronze"
    And I should not see badge "chauffer_silver_medium"
    When I have "3" testimonials with grade "1" from category "rideshare" as "offerer"
    And I get "1" testimonial with grade "positive" from category "rideshare"
    Then I get the badge "chauffer_silver"
    And I should not see badge "chauffer_gold_medium"
    When I have "8" testimonials with grade "1" from category "rideshare" as "offerer"
    And I get "1" testimonial with grade "positive" from category "rideshare"
    Then I get the badge "chauffer_gold"
    
  @badge
  @javascript
  Scenario: User views helper badge
    Given I should not see badge "helper_bronze_medium"
    And I have "1" testimonial with grade "1" from category "favor" as "offerer"
    And I should not see badge "helper_bronze_medium"
    When I get "1" testimonial with grade "positive" from category "favor"
    Then I get the badge "helper_bronze"
    And I should not see badge "helper_silver_medium"
    When I have "3" testimonials with grade "1" from category "favor" as "offerer"
    And I get "1" testimonial with grade "positive" from category "favor"
    Then I get the badge "helper_silver"
    And I should not see badge "helper_gold_medium"
    When I have "8" testimonials with grade "1" from category "favor" as "offerer"
    And I get "1" testimonial with grade "positive" from category "favor"
    Then I get the badge "helper_gold"
    
  @badge
  @javascript
  Scenario: User views generous badge
    Given I should not see badge "generous_bronze_medium"
    And I have "1" testimonial with grade "1" from category "item" as "offerer" with share type "lend"
    And I should not see badge "generous_bronze_medium"
    When I get "1" testimonial with grade "positive" from category "item" with share type "give_away"
    Then I get the badge "generous_bronze"
    And I should not see badge "generous_silver_medium"
    When I have "3" testimonials with grade "1" from category "item" as "offerer" with share type "lend"
    And I get "1" testimonial with grade "positive" from category "item" with share type "lend"
    Then I get the badge "generous_silver"
    And I should not see badge "generous_gold_medium"
    When I have "8" testimonials with grade "1" from category "item" as "offerer" with share type "lend"
    And I get "1" testimonial with grade "positive" from category "item" with share type "lend"
    Then I get the badge "generous_gold"
    
  @badge
  @javascript
  Scenario: User views moneymaker badge
    Given I should not see badge "moneymaker_bronze_medium"
    And I have "1" testimonial with grade "1" from category "item" as "offerer" with share type "sell"
    And I should not see badge "moneymaker_bronze_medium"
    When I get "1" testimonial with grade "positive" from category "item" with share type "rent_out"
    Then I get the badge "moneymaker_bronze"
    And I should not see badge "moneymaker_silver_medium"
    When I have "3" testimonials with grade "1" from category "item" as "offerer" with share type "sell"
    And I get "1" testimonial with grade "positive" from category "item" with share type "rent_out"
    Then I get the badge "moneymaker_silver"
    And I should not see badge "moneymaker_gold_medium"
    When I have "8" testimonials with grade "1" from category "item" as "offerer" with share type "sell"
    And I get "1" testimonial with grade "positive" from category "item" with share type "sell"
    Then I get the badge "moneymaker_gold"
  
  @badge
  @javascript
  Scenario: User views volunteer badge
    Given I should not see badge "volunteer_bronze_medium"
    When I have "2" favor offer listings
    And I create a new favor offer listing
    Then I get the badge "volunteer_bronze"
    And I should not see badge "volunteer_silver_medium"
    When I have "6" favor offer listings
    And I create a new favor offer listing
    Then I get the badge "volunteer_silver"
    And I should not see badge "volunteer_gold_medium"
    When I have "14" favor offer listings
    And I create a new favor offer listing
    Then I get the badge "volunteer_gold"
    
  @badge
  @javascript
  Scenario: User views lender badge
    Given I should not see badge "lender_bronze_medium"
    When I have "2" item offer listings with share type "lend"
    And I create a new item offer listing with share type "lend"
    Then I get the badge "lender_bronze"
    And I should not see badge "lender_silver_medium"
    When I have "6" item offer listings with share type "lend"
    And I create a new item offer listing with share type "lend"
    Then I get the badge "lender_silver"
    And I should not see badge "lender_gold_medium"
    When I have "14" item offer listings with share type "lend"
    And I create a new item offer listing with share type "lend"
    Then I get the badge "lender_gold"
  
  @badge
  @javascript
  Scenario: User views taxi stand badge
    Given I should not see badge "taxi_stand_bronze_medium"
    When I have "2" rideshare offer listings
    And I create a new rideshare offer listing
    Then I get the badge "taxi_stand_bronze"
    And I should not see badge "taxi_stand_silver_medium"
    When I have "6" rideshare offer listings
    And I create a new rideshare offer listing
    Then I get the badge "taxi_stand_silver"
    And I should not see badge "taxi_stand_gold_medium"
    When I have "14" rideshare offer listings
    And I create a new rideshare offer listing
    Then I get the badge "taxi_stand_gold"