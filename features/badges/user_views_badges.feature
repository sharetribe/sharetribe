Feature: User views badges
  In order to view what achievements I have accomplished in Kassi
  As a user
  I want to be able to view my badges
  
  @javascript
  Scenario: User views badges while belonging to different test groups
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And I am logged in as "kassi_testperson2"
    And I create a new favor offer listing
    And I follow "Logout"
    And I log in as "kassi_testperson1"
    And I have "2" testimonials with grade "0.5"
    And I get "1" testimonial with grade "As expected"
    When I belong to test group "1"
    And I go to the badges page of "kassi_testperson1"
    Then I should see badge "active_member_bronze_medium"
    And I should not see badge "active_member_bronze_medium_gray"
    When I go to the profile page of "kassi_testperson2"
    Then I should not see "Badges"
    When I go to the badges page of "kassi_testperson2"
    Then I should not see badge "rookie_medium"
    And I should see "No received feedback"
    When I belong to test group "2"
    And I go to the badges page of "kassi_testperson1"
    Then I should see badge "active_member_bronze_medium"
    And I should not see badge "active_member_bronze_medium_gray"
    When I go to the profile page of "kassi_testperson2"
    Then I should see "Badges"
    When I go to the badges page of "kassi_testperson2"
    Then I should see badge "rookie_medium"
    And I should not see badge "active_member_bronze_medium_gray"
    When I belong to test group "3"
    And I go to the badges page of "kassi_testperson1"
    Then I should see badge "active_member_bronze_medium"
    And I should see badge "active_member_silver_medium_gray"
    When I go to the profile page of "kassi_testperson2"
    Then I should not see "Badges"
    When I go to the badges page of "kassi_testperson2"
    Then I should not see badge "rookie_medium"
    And I should see "No received feedback"
    When I belong to test group "4"
    And I go to the badges page of "kassi_testperson1"
    Then I should see badge "active_member_bronze_medium"
    And I should see badge "active_member_silver_medium_gray"
    When I go to the profile page of "kassi_testperson2"
    Then I should see "Badges"
    When I go to the badges page of "kassi_testperson2"
    Then I should see badge "rookie_medium"
    And I should see badge "active_member_bronze_medium_gray"
    When I follow "Logout"
    And I go to the badges page of "kassi_testperson1"
    Then I should not see badge "active_member_bronze_medium"
    And I should see "Feedback average:"
    When I go to the profile page of "kassi_testperson1"
    Then I should not see "Badges"
    
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
    When I have "14" testimonials with grade "0.5"
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
  
  # This badge is not in use for now.
  # @badge
  # @javascript
  # Scenario: User views enthusiast badge
  #   Given I should see badge "enthusiast_bronze_medium_gray"
  #   And I should not see badge "enthusiast_bronze_medium"
  #   When I have visited Kassi on "4" different days
  #   And I go to the home page
  #   And the system processes jobs
  #   Then I get the badge "enthusiast_bronze"
  #   And I should not see badge "enthusiast_silver_medium"
  #   When I have visited Kassi on "29" different days
  #   And I go to the home page
  #   And the system processes jobs
  #   Then I get the badge "enthusiast_silver"
  #   And I should not see badge "enthusiast_gold_medium"
  #   When I have visited Kassi on "99" different days
  #   And I go to the home page
  #   And the system processes jobs
  #   Then I get the badge "enthusiast_gold"
    
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
  
  @badge
  @javascript
  Scenario: User views chauffer badge
    Given I should see badge "chauffer_bronze_medium_gray"
    And I should not see badge "chauffer_bronze_medium"
    And I have "1" testimonial with grade "0.5" from category "rideshare" as "offerer"
    And I should not see badge "chauffer_bronze_medium"
    When I get "1" testimonial with grade "As expected" from category "rideshare"
    Then I get the badge "chauffer_bronze"
    And I should not see badge "chauffer_silver_medium"
    When I have "3" testimonials with grade "0.5" from category "rideshare" as "offerer"
    And I get "1" testimonial with grade "As expected" from category "rideshare"
    Then I get the badge "chauffer_silver"
    And I should not see badge "chauffer_gold_medium"
    When I have "8" testimonials with grade "0.5" from category "rideshare" as "offerer"
    And I get "1" testimonial with grade "As expected" from category "rideshare"
    Then I get the badge "chauffer_gold"
    
  @badge
  @javascript
  Scenario: User views helper badge
    Given I should see badge "helper_bronze_medium_gray"
    And I should not see badge "helper_bronze_medium"
    And I have "1" testimonial with grade "0.5" from category "favor" as "offerer"
    And I should not see badge "helper_bronze_medium"
    When I get "1" testimonial with grade "As expected" from category "favor"
    Then I get the badge "helper_bronze"
    And I should not see badge "helper_silver_medium"
    When I have "3" testimonials with grade "0.5" from category "favor" as "offerer"
    And I get "1" testimonial with grade "As expected" from category "favor"
    Then I get the badge "helper_silver"
    And I should not see badge "helper_gold_medium"
    When I have "8" testimonials with grade "0.5" from category "favor" as "offerer"
    And I get "1" testimonial with grade "As expected" from category "favor"
    Then I get the badge "helper_gold"
    
  @badge
  @javascript
  Scenario: User views generous badge
    Given I should see badge "generous_bronze_medium_gray"
    And I should not see badge "generous_bronze_medium"
    And I have "1" testimonial with grade "0.5" from category "item" as "offerer" with share type "lend,give_away"
    And I should not see badge "generous_bronze_medium"
    When I get "1" testimonial with grade "As expected" from category "item" with share type "give_away"
    Then I get the badge "generous_bronze"
    And I should not see badge "generous_silver_medium"
    When I have "3" testimonials with grade "0.5" from category "item" as "offerer" with share type "lend,give_away"
    And I get "1" testimonial with grade "As expected" from category "item" with share type "lend,give_away"
    Then I get the badge "generous_silver"
    And I should not see badge "generous_gold_medium"
    When I have "8" testimonials with grade "0.5" from category "item" as "offerer" with share type "lend,give_away"
    And I get "1" testimonial with grade "As expected" from category "item" with share type "lend,give_away"
    Then I get the badge "generous_gold"
    
  @badge
  @javascript
  Scenario: User views moneymaker badge
    Given I should see badge "moneymaker_bronze_medium_gray"
    And I should not see badge "moneymaker_bronze_medium"
    And I have "1" testimonial with grade "0.5" from category "item" as "offerer" with share type "sell"
    And I should not see badge "moneymaker_bronze_medium"
    When I get "1" testimonial with grade "As expected" from category "item" with share type "rent_out"
    Then I get the badge "moneymaker_bronze"
    And I should not see badge "moneymaker_silver_medium"
    When I have "3" testimonials with grade "0.5" from category "item" as "offerer" with share type "sell"
    And I get "1" testimonial with grade "As expected" from category "item" with share type "rent_out"
    Then I get the badge "moneymaker_silver"
    And I should not see badge "moneymaker_gold_medium"
    When I have "8" testimonials with grade "0.5" from category "item" as "offerer" with share type "sell,rent_out"
    And I get "1" testimonial with grade "As expected" from category "item" with share type "sell,rent_out"
    Then I get the badge "moneymaker_gold"
  
  @badge
  @javascript
  Scenario: User views volunteer badge
    Given I should see badge "volunteer_bronze_medium_gray"
    And I should not see badge "volunteer_bronze_medium"
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
    Given I should see badge "lender_bronze_medium_gray"
    And I should not see badge "lender_bronze_medium"
    When I have "2" item offer listings with share type "lend"
    And I create a new item offer listing with share type "lend,sell"
    Then I get the badge "lender_bronze"
    And I should not see badge "lender_silver_medium"
    When I have "6" item offer listings with share type "lend,give_away"
    And I create a new item offer listing with share type "lend"
    Then I get the badge "lender_silver"
    And I should not see badge "lender_gold_medium"
    When I have "14" item offer listings with share type "lend"
    And I create a new item offer listing with share type "lend"
    Then I get the badge "lender_gold"
  
  @badge
  @javascript
  Scenario: User views taxi stand badge
    Given I should see badge "taxi_stand_bronze_medium_gray"
    And I should not see badge "taxi_stand_bronze_medium"
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