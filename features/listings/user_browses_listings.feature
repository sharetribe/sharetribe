Feature: User browses listings
  In order to find out what kind of offers and requests there are available in Sharetribe
  As a person who needs something or has something
  I want to be able to browse offers and requests

  @javascript
  Scenario: User browses offers page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "car spare parts" from "kassi_testperson2" and with share type "sell"
    And there is favor offer with title "massage" from "kassi_testperson1"
    And there is rideshare offer from "Helsinki" to "Turku" by "kassi_testperson1"
    And there is housing offer with title "Apartment" from "kassi_testperson2" and with share type "sell"
    And there is item offer with title "saw" from "kassi_testperson2" and with share type "lend"
    And there is item offer with title "axe" from "kassi_testperson2" and with share type "lend"
    And that listing is closed
    And there is item request with title "tool" from "kassi_testperson2" and with share type "buy"
    And I am on the home page
    When I follow "Offers"
    Then I should see "car spare parts"
    And I should see "massage"
    And I should see "Helsinki - Turku"
    And I should see "Apartment"
    And I should see "saw"
    And I should not see "axe"
    And I should not see "tool"
    And I follow "Items"
    And I should see "car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should see "saw"
    And I should not see "axe"
    And I should not see "tool"
    And I follow "Lending"
    And I should not see "car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should see "saw"
    And I should not see "axe"
    And I should not see "tool"
    And I follow "Selling"
    And I should see "car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should see "saw"
    And I should not see "axe"
    And I should not see "tool"
    And I follow "Services"
    And I should not see "car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "saw"
    And I should not see "axe"
    And I should not see "tool"
    And I follow "All offer types"
    And I should not see "car spare parts"
    And I should see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "saw"
    And I should not see "axe"
    And I should not see "tool"
    
  @javascript
  Scenario: User browses requests page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item request with title "car spare parts" from "kassi_testperson2" and with share type "buy"
    And there is favor request with title "massage" from "kassi_testperson1"
    And there is rideshare request from "Helsinki" to "Turku" by "kassi_testperson1"
    And there is housing request with title "Apartment" from "kassi_testperson2" and with share type "buy"
    And there is item request with title "saw" from "kassi_testperson2" and with share type "borrow"
    And there is item request with title "axe" from "kassi_testperson2" and with share type "borrow"
    And that listing is closed
    And there is item offer with title "tool" from "kassi_testperson2" and with share type "sell"
    And I am on the home page
    When I follow "Requests"
    Then I should see "car spare parts"
    And I should see "massage"
    And I should see "Helsinki - Turku"
    And I should see "Apartment"
    And I should see "saw"
    And I should not see "axe"
    And I should not see "tool"
    And I follow "Items"
    And I should see "car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should see "saw"
    And I should not see "axe"
    And I should not see "tool"
    And I follow "Borrowing"
    And I should not see "car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should see "saw"
    And I should not see "axe"
    And I should not see "tool"
    And I follow "Buying"
    And I should see "car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should see "saw"
    And I should not see "axe"
    And I should not see "tool"
    And I follow "Services"
    And I should not see "car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "saw"
    And I should not see "axe"
    And I should not see "tool"
    And I follow "All request types"
    And I should not see "car spare parts"
    And I should see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "saw"
    And I should not see "axe"
    And I should not see "tool"
    
  @javascript
  Scenario: User browses requests with visibility settings
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item request with title "car spare parts" from "kassi_testperson2" and with share type "buy"
    And visibility of that listing is "this_community"
    And there is favor request with title "massage" from "kassi_testperson1"
    And there is housing request with title "apartment" and with share type "rent"
    And visibility of that listing is "disabled"
    And I am on the requests page
    And I should not see "car spare parts"
    And I should see "massage"
    And I should not see "apartment"
    When I log in as "kassi_testperson1"
    And I follow "Requests"
    Then I should see "car spare parts"
    And I should see "massage"
    And I should not see "apartment"
    
  @pending
  @javascript
  Scenario: User browses offers page with tags
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "car spare parts" from "kassi_testperson2" and with share type "sell" and with tags "car"
    And there is item offer with title "other car spare parts" from "kassi_testperson2" and with share type "sell" and with tags "car"
    And there is favor offer with title "massage" from "kassi_testperson1" and with tags "service"
    And there is rideshare offer from "Helsinki" to "Turku" by "kassi_testperson1"
    And there is housing offer with title "Apartment" from "kassi_testperson2" and with share type "sell"
    And there is item offer with title "axe" from "kassi_testperson2" and with share type "lend" and with tags "tool"
    And that listing is closed
    And I am on the home page
    When I follow "Offers"
    Then I should see "car spare parts"
    And I should see "other car spare parts"
    And I should see "massage"
    And I should see "Helsinki - Turku"
    And I should see "Apartment"
    And I should not see "tool"
    And I should not see "axe"
    And I follow "Services"
    And I should not see "car spare parts"
    And I should not see "other car spare parts"
    And I should see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "axe"
    And I follow "car"
    And I should see "car spare parts"
    And I should see "other car spare parts"
    And I should see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "axe"
    And I follow "Services"
    And I should see "car spare parts"
    And I should see "other car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "axe"

  @javascript
  @subdomain2
  Scenario: User browses requests in a different subdomain
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item request with title "car spare parts" from "kassi_testperson1" and with share type "buy"
    And visibility of that listing is "this_community"
    And there is favor request with title "massage" from "kassi_testperson2"
    And visibility of that listing is "all_communities"
    And there is item request with title "saw" from "kassi_testperson2" and with share type "buy"
    And visibility of that listing is "all_communities"
    And that listing is visible to members of community "test2"
    When I am on the homepage
    Then I should not see "car spare parts"
    And I should not see "massage"
    And I should not see "saw"
    When I log in as "kassi_testperson2"
    Then I should not see "car spare parts"
    And I should not see "massage"
    And I should see "saw"
