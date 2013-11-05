Feature: User views homepage
  In order to see the latest activity in Sharetribe
  As a user
  I want see latest offers, requests and transactions on the home page
  
  @javascript
  Scenario: Latest offers on the homepage
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item offer with title "car spare parts" from "kassi_testperson1" and with share type "sell"
    And there is item offer with title "bike" from "kassi_testperson1" and with share type "sell"
    And that listing is closed
    And there is item request with title "saw" from "kassi_testperson2" and with share type "buy"
    And privacy of that listing is "private"
    When I am on the homepage
    And I should see "car spare parts"
    And I should not see "bike"
    And I should not see "saw"
    And I log in as "kassi_testperson1"
    Then I should see "saw"
    And I should see "car spare parts"
    And I should not see "bike"
  
  @javascript
  Scenario: Latest requests on the homepage
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "massage" from "kassi_testperson2"
    And I am logged in as "kassi_testperson1"
    When I am on the homepage
    Then I should see "massage"
    And I should not see "offer item"
  
  @javascript
  Scenario: User browses homepage with requests with visibility settings
     Given there are following users:
       | person | 
       | kassi_testperson1 |
     And there is item request with title "car spare parts" from "kassi_testperson2" and with share type "buy"
     And privacy of that listing is "private"
     And there is favor request with title "massage" from "kassi_testperson1"
     And there is housing request with title "place to live" and with share type "rent"
     And visibility of that listing is "all_communities"
     And privacy of that listing is "private"
     And I am on the home page page
     And I should not see "car spare parts"
     And I should see "massage"
     And I should not see "place to live"
     When I log in as "kassi_testperson1"
     Then I should see "car spare parts"
     And I should see "massage"
     And I should see "place to live"
     
  @javascript
  @subdomain2
  Scenario: User browses homepage in a different subdomain
    Given there are following users:
       | person | 
       | kassi_testperson1 |
       | kassi_testperson2 |
    And there is item request with title "car spare parts" from "kassi_testperson1" and with share type "buy"
    And privacy of that listing is "private"
    And there is favor request with title "massage" from "kassi_testperson2"
    And visibility of that listing is "all_communities"
    And there is item request with title "saw" from "kassi_testperson2" and with share type "buy"
    And visibility of that listing is "all_communities"
    And privacy of that listing is "private"
    And that listing is visible to members of community "test2"
    When I am on the homepage
    Then I should not see "car spare parts"
    And I should not see "massage"
    And I should not see "saw"
    When I log in as "kassi_testperson2"
    Then I should not see "car spare parts"
    And I should not see "massage"
    And I should see "saw"
  
  @javascript
  Scenario: User browses homepage when there is no content
    Given there are following users:
       | person | 
       | kassi_testperson1 |
    When I am on the homepage
    When I log in as "kassi_testperson2"
    When there is item request with title "car spare parts" from "kassi_testperson1" and with share type "buy"
    And I am on the homepage
    When there is item offer with title "car spare parts" from "kassi_testperson1" and with share type "sell"
    And I am on the homepage
    Then I should not see "No open item, service or rideshare requests."
    And I should not see "No open item, service or rideshare offers."
  
  @javascript
  Scenario: User browses homepage when there are only private listings. He should see blank slates
     Given there are following users:
       | person | 
       | kassi_testperson1 |
     And there is item offer with title "car spare parts" from "kassi_testperson2" and with share type "sell"
     And privacy of that listing is "private"
     And there is housing request with title "place to live" and with share type "rent"
     And privacy of that listing is "private"
     And I am on the home page page
     And I should not see "car spare parts"
     And I should not see "place to live"
     When there is item request with title "bike parts" from "kassi_testperson2" and with share type "buy"
     And privacy of that listing is "private"
     And I am on the homepage
     Then I should not see "bike parts"
  
  @wip
  @javascript
  Scenario: User views event feed
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    When I am on the homepage
    And THIS SCENARIO IS NOT CURRENTLY IN USE AS EVENT FEED IS NOT VISIBLE
    And I should not see "Latest events"
    When I go to the signup page
    And I fill in "person[username]" with random username
    And I fill in "Given name" with "Chuck"
    And I fill in "Family name" with "The Man"
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with random email
    And I check "person_terms"
    And I press "Create account"
    And the system processes jobs
    Then I should not see "Chuck joined Test Sharetribe"
    When I click ".user-menu-toggle"
    And I follow "Log out"
    And I log in as "kassi_testperson1"
    And the system processes jobs
    Then I should not see "logged in to Sharetribe."
    When there is item offer with title "hammer" from "kassi_testperson2" and with share type "lend"
    And privacy of that listing is "public"
    And I go to the homepage
    And I follow "hammer"
    And I fill in "comment_content" with "Test comment"
    And I press "Send comment"
    And the system processes jobs
    And I go to the homepage
    Then I should see "Chuck joined Test Sharetribe"
    And I should see "logged in to Sharetribe"
    And I should see "commented on offer hammer"
    And the total number of comments should be 1
    When I follow "Lending: hammer"
    And I follow "Borrow this item"
    And I fill in "Message:" with "I want to borrow this item"
    And I press "Send message"
    When I click ".user-menu-toggle"
    And I follow "Log out"
    And I log in as "kassi_testperson2"
    When I follow "inbox-link"
    And I follow "Accept"
    And the system processes jobs
    And I go to the home page
    Then I should see "agreed to lend hammer to"
    When there is item offer with title "power drill" from "kassi_testperson2" and with share type "lend"
    And privacy of that listing is "private"
    And I am on the home page
    And I follow "power drill"
    And I fill in "comment_content" with "Test comment"
    And I press "Send comment"
    And the system processes jobs
    Then I should see "Comment sent"
    And the total number of comments should be 2
    When I click ".user-menu-toggle"
    And I follow "Log out"
    Then I should not see "commented offer power drill"
    And the system processes jobs
    When I log in as "kassi_testperson1"
    Then I should see "commented on offer power drill"
  
  @pending
  Scenario: Latest transactions on the homepage
    Given the latest transaction is "Johnny offered an item drill to Bill" #This Given needs better structure
    When I am on the homepage
    Then I should see "Johnny offered an item drill to Bill"
    
  @pending
  Scenario: Endless scrolling
    Given there are 13 open offers
    And the oldest offer has title "course books"
    And I am on the home page
    And I do not see "course books"
    When I scroll to the bottom of the page
    And wait for 2 seconds
    Then I should see "course books"
    
  @javascript
  Scenario: Superadmin views a community he is not a member of
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    When I am logged in as "kassi_testperson1"
    And I move to community "test2"
    And "kassi_testperson1" is superadmin
    And I am on the home page
    Then I should not see "Join community"
    And I should see "Post a new listing"