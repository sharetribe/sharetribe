Feature: User browses listings
  In order to find out what kind of offers and requests there are available in Sharetribe
  As a person who needs something or has something
  I want to be able to browse offers and requests


  @javascript @sphinx @no-transaction
  Scenario: User browses offers page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "car spare parts" from "kassi_testperson2" with category "Items" and with transaction type "Selling"
    And there is a listing with title "massage" from "kassi_testperson1" with category "Services" and with transaction type "Selling services"
    And there is a listing with title "Helsinki - Turku" from "kassi_testperson1" with category "Services" and with transaction type "Selling services"
    And there is a listing with title "Apartment" from "kassi_testperson2" with category "Spaces" and with transaction type "Selling"
    And there is a listing with title "saw" from "kassi_testperson2" with category "Items" and with transaction type "Lending"
    And there is a listing with title "axe" from "kassi_testperson2" with category "Items" and with transaction type "Lending"
    And that listing is closed
    And there is a listing with title "toolbox" from "kassi_testperson2" with category "Items" and with transaction type "Requesting"
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
    And I should see "Apartment"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "saw"
    And I should not see "axe"
    And I should not see "toolbox"
    And I follow "Services"
    And I should not see "massage"
    And I should not see "Helsinki - Turku"
    And I should not see "car spare parts"
    And I should not see "Apartment"
    And I should not see "saw"
    And I should not see "axe"
    And I should not see "toolbox"
    When I choose to view only transaction type "All listing types"
    And I should not see "car spare parts"
    And I should see "massage"
    And I should see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "saw"
    And I should not see "axe"
    And I should not see "toolbox"
  
  @javascript @sphinx @no-transaction
  Scenario: User browses requests page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "car spare parts" from "kassi_testperson2" with category "Items" and with transaction type "Requesting"
    And there is a listing with title "massage" from "kassi_testperson1" with category "Services" and with transaction type "Requesting"
    And there is a listing with title "Helsinki - Turku" from "kassi_testperson1" with category "Services" and with transaction type "Requesting"
    And there is a listing with title "Apartment" from "kassi_testperson2" with category "Spaces" and with transaction type "Requesting"
    And there is a listing with title "saw" from "kassi_testperson2" with category "Items" and with transaction type "Requesting"
    And there is a listing with title "axe" from "kassi_testperson2" with category "Items" and with transaction type "Requesting"
    And that listing is closed
    And there is a listing with title "toolbox" from "kassi_testperson2" with category "Items" and with transaction type "Selling"
    And the Listing indexes are processed

    When I am on the home page
    When I choose to view only transaction type "Request"
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
    And I follow "Services"
    And I should not see "car spare parts"
    And I should see "massage"
    And I should see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "saw"
    And I should not see "axe"
    And I should not see "toolbox"
    When I choose to view only transaction type "All listing types"
    And I should not see "car spare parts"
    And I should see "massage"
    And I should see "Helsinki - Turku"
    And I should not see "Apartment"
    And I should not see "saw"
    And I should not see "axe"
    And I should not see "toolbox"
    
  @javascript @sphinx @no-transaction
  Scenario: User browses requests with visibility settings
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is a listing with title "car spare parts" from "kassi_testperson2" with category "Items" and with transaction type "Requesting"
    And privacy of that listing is "private"
    And there is a listing with title "massage" from "kassi_testperson1" with category "Services" and with transaction type "Requesting"
    And there is a listing with title "apartment" with category "Spaces" and with transaction type "Requesting"
    And visibility of that listing is "this_community"
    And privacy of that listing is "private"
    And that listing is closed
    And the Listing indexes are processed

    When I am on the home page
    When I choose to view only transaction type "Request"
    Then I should not see "car spare parts"
    And I should see "massage"
    And I should not see "apartment"
    When I log in as "kassi_testperson1"
    When I choose to view only transaction type "Request"
    Then I should see "car spare parts"
    And I should see "massage"
    And I should not see "apartment"