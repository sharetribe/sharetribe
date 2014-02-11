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
    And there is item request with title "toolbox" from "kassi_testperson2" and with share type "buy"
    And I am on the home page
    And the Listing indexes are processed
    When I choose to view only transaction type "Lending"
    And I should not see "car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should see "saw" 
    And I should not see "axe"
    And I should not see "toolbox"
    When I choose to view only transaction type "Selling"
    And I should see "car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "saw"
    And I should not see "axe"
    And I should not see "toolbox"
    And I follow "Services"
    And I should not see "car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "saw"
    And I should not see "axe"
    And I should not see "toolbox"
    When I choose to view only transaction type "All listing types"
    And I should not see "car spare parts"
    And I should see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "saw"
    And I should not see "axe"
    And I should not see "toolbox"
  
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
    And there is item offer with title "toolbox" from "kassi_testperson2" and with share type "sell"
    And the Listing indexes are processed

    When I am on the home page
    When I choose to view only share type "Request"
    Then I should see "car spare parts"
    And I should see "massage"
    And I should see "Helsinki - Turku"
    And I should see "Apartment"
    And I should see "saw"
    And I should not see "axe"
    And I should not see "toolbox"
    And I follow "Items"
    And I should see "car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should see "saw"
    And I should not see "axe"
    And I should not see "toolbox"
    When I choose to view only share type "Borrowing"
    And I should not see "car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should see "saw"
    And I should not see "axe"
    And I should not see "toolbox"
    When I choose to view only share type "Buying"
    And I should see "car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "saw"
    And I should not see "axe"
    And I should not see "toolbox"
    And I follow "Services"
    And I should not see "car spare parts"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "saw"
    And I should not see "axe"
    And I should not see "toolbox"
    When I choose to view only share type "All listing types"
    And I should not see "car spare parts"
    And I should see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "saw"
    And I should not see "axe"
    And I should not see "toolbox"
    
  @javascript
  Scenario: User browses requests with visibility settings
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item request with title "car spare parts" from "kassi_testperson2" and with share type "buy"
    And privacy of that listing is "private"
    And there is favor request with title "massage" from "kassi_testperson1"
    And there is housing request with title "apartment" and with share type "rent"
    And visibility of that listing is "this_community"
    And privacy of that listing is "private"
    And that listing is closed
    And the Listing indexes are processed

    When I am on the home page
    When I choose to view only share type "Request"
    Then I should not see "car spare parts"
    And I should see "massage"
    And I should not see "apartment"
    When I log in as "kassi_testperson1"
    When I choose to view only share type "Request"
    Then I should see "car spare parts"
    And I should see "massage"
    And I should not see "apartment"

  @javascript
  @subdomain2
  Scenario: User browses requests in a different subdomain
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
