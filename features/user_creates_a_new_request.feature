Feature: User creates a new request
  In order to perform a certain task using an item, a skill, or a transport 
  As a person who does not have the required item, skill, or transport
  I want to be able to request an item, a favor, or transport I need from other users
  
  Scenario: Creating a new item request successfully
    Given I am logged in
    And I am on the home page
    When I follow "Request something"
    And I fill in "listing_title" with "My request"
    And I press "Save request"
    Then I should see "Request: My request" within "h1"
    And I should see "Request created successfully" within "#notifications"
    
  Scenario: Trying to create a new request without being logged in
    Given I am not logged in
    And I am on the home page
    When I follow "Request something"
    Then I should see "Request created successfully" within "#notifications"
    And I should see a warning notification that says "You need to log in to request something"

  Scenario: Creating a new favor request successfully
    Given I am at the home page
    And I am logged in
    When I click the "Request something" button
    And I fill in the following:
      | Title | "My request" |
    And I click the "Favor" button
    And I write a title for the request
    And I click the "Save request" button
    Then a new listing of type request should be created with the information I provided
    And I should be redirected to the page of the new listing
    And I should see a success notification that says "Listing created successfully"

  Scenario: Creating a new rideshare request successfully
    Given I am at the home page
    And I am logged in
    When I click the "Request something" button
    And I click the "Rideshare" button
    And I write a title for the request
    And I click the "Save request" button 
    Then a new listing of type request should be created with the information I provided
    And I should be redirected to the page of the new listing
    And I should see a success notification that says "Listing created successfully"

  Scenario: Trying to create a new request without being logged in
    Given I am at the home page
    And I am not logged in
    When I click the "Request something" button
    Then I should be redirected to the login page
    And I should see a warning notification that says "You need to log in to request something"

  Scenario: Trying to create a new item request without title
    Given I am at the home page
    And I am logged in
    When I click the "Request something" button
    And I click the "Save request" button
    Then I should stay on the page "Create a new request"
    And I should see an error message "You must provide a title for your request" below the "Title" textfield