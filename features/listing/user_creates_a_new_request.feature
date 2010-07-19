Feature: User creates a new request
  In order to get an item, a favor, or a ride
  As a person who needs to perform a certain task
  I want to be able to request the item, favor, or ride I need from other users
  
  Scenario: Creating a new request successfully
    Given I am at the home page
    And I am logged in
    When I click the "Request something" button
    And I write a title for the request
    Then a new listing of type request should be created with the information I provided
    And I should be redirected to the page of the new listing
    And I should see a success notification that says "Listing created successfully"

  Scenario: Trying to create a new request without being logged in
    Given I am at the home page
    And I am not logged in
    When I click the "Request something" button
    Then I should be redirected to the login page
    And I should see a warning notification that says "You need to log in to create a new listing"

  Scenario: Trying to create a new request with insufficient information
    Given I am at the home page
    And I am logged in
    When I click the "Request something" button
    And I click the "Save request" button
    Then I should stay on the page "Create a new request"
    And I should see an error message "You must provide a title for your request" below the "Title" textfield
    And I should see the title I wrote in the "Item you need" textfield