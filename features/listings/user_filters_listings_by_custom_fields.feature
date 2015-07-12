@sphinx @no-transaction
Feature: Custom field filters
  In order to view only listings that match certain marketplace specific condition
  As a user
  I want to be able to easily select which listings are shown

  Background:
    Given there is a dropdown field "House type" for category "Spaces" in community "test" with options:
      | title |
      | condo |
      | house |
    And there is a dropdown field "Balcony type" for category "Spaces" in community "test" with options:
      | title  |
      | glazed |
      | open   |

    And there is a listing with title "Apartment" from "kassi_testperson2" with category "Spaces" and with listing shape "Selling services"
    And that listing has custom field "House type" with value "condo"
    And that listing has custom field "Balcony type" with value "open"
    And there is a listing with title "Country house" from "kassi_testperson2" with category "Spaces" and with listing shape "Selling services"
		And that listing has custom field "House type" with value "house"
    And that listing has custom field "Balcony type" with value "glazed"
    And there is a listing with title "Small house" from "kassi_testperson2" with category "Spaces" and with listing shape "Selling services"
		And that listing has custom field "House type" with value "house"
    And that listing has custom field "Balcony type" with value "open"
    And there is a listing with title "Tent" from "kassi_testperson2" with category "Spaces" and with listing shape "Selling services"
    
    And I am on the home page
    And the Listing indexes are processed

  @javascript
  Scenario: User filters listings by custom field filters
    When I check "condo"
    And I press "Update view"
    Then I should see "Apartment"
    And I should not see "Country house"
  	And I should not see "Small House"
  	And I should not see "Tent"

  	When I check "house"
  	And I press "Update view"
		Then I should see "Apartment"
    And I should see "Country house"
  	And I should see "Small house"  	
  	And I should not see "Tent"

  	When I uncheck "condo"
  	And I press "Update view"
		Then I should not see "Apartment"
    And I should see "Country house"
  	And I should see "Small house"  	
  	And I should not see "Tent"

  	And I check "open"
		And I press "Update view"
		Then I should not see "Apartment"
    And I should not see "Country house"
  	And I should see "Small house"
  	And I should not see "Tent"

  	When I uncheck "house"
  	And I press "Update view"
  	Then I should see "Apartment"
    And I should not see "Country house"
  	And I should see "Small house"
  	And I should not see "Tent"

  	When I check "glazed"
  	And I press "Update view"
  	Then I should see "Apartment"
    And I should see "Country house"
  	And I should see "Small house"
  	And I should not see "Tent"

  	When I check "house"
  	And I press "Update view"
  	Then I should not see "Apartment"
    And I should see "Country house"
  	And I should see "Small house"
  	And I should not see "Tent"

  	When I uncheck "house"
  	And I uncheck "open"
  	And I uncheck "glazed"
  	And I press "Update view"
  	Then I should see "Apartment"
    And I should see "Country house"
  	And I should see "Small house"
  	And I should see "Tent"

@javascript @sphinx @no-transaction
Scenario: User combines custom filters with search and category
	Given there is a listing with title "country and house music cd" from "kassi_testperson2" with category "Items" and with listing shape "Selling services"
  And the Listing indexes are processed
  
  When I fill in "q" with "country"
  And I press "search-button"

  Then I should see "Country house"
  And I should see "country and house music cd"
  And I should not see "Small house"

  When I follow "Spaces"
  Then I should see "Country house"
  And I should not see "country and house music cd"
	And I should not see "Small house"

	When I fill in "q" with "house"
  And I press "search-button"
  Then I should see "Country house"
  And I should not see "country and house music cd"
	And I should see "Small house"

	When I follow "All categories"
	Then I should see "Country house"
  And I should see "country and house music cd"
	And I should see "Small house" 

	When I check "open"
	And I press "Update view"
  Then I should not see "Country house"
  And I should not see "country and house music cd"
	And I should see "Small house"

	When I fill in "q" with ""
	And I press "search-button"
	Then I should not see "Country house"
  And I should not see "country and house music cd"
	And I should see "Small house"
	And I should see "Apartment"

	When I uncheck "open"
	And I press "Update view"
	Then I should see "Country house"
  And I should see "country and house music cd"
	And I should see "Small house"
	And I should see "Apartment"
	And I should see "Tent"

	


  





