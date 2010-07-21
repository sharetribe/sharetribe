Feature: User creates a new offer
  In order to get reciprocal value or to help others
  As a person who has an item, is able to do a favor, or owns a transport
  I want to be able to offer that item, favor, or transport to the other users
  
  Scenario: Creating a new item offer successfully
    Given I am at the home page
    And I am logged in
    When I click the "Offer something" button
    And I write a title for the offer
    And I click the "Save offer" button
    Then a new listing of type offer should be created with the information I provided
    And I should be redirected to the page of the new listing
    And I should see a success notification that says "Offer created successfully"

  Scenario: Creating a new favor offer successfully
    Given I am at the home page
    And I am logged in
    When I click the "Offer something" button
    And I click the "Favor" button
    And I write a title for the offer
    And I click the "Save offer" button
    Then a new listing of type offer should be created with the information I provided
    And I should be redirected to the page of the new listing
    And I should see a success notification that says "Offer created successfully"

  Scenario: Creating a new favor offer successfully
    Given I am at the home page
    And I am logged in
    When I click the "Offer something" button
    And I click the "Rideshare" button
    And I write a title for the offer
    And I click the "Save offer" button
    Then a new listing of type offer should be created with the information I provided
    And I should be redirected to the page of the new listing
    And I should see a success notification that says "Offer created successfully"

  Scenario: Trying to create a new offer without being logged in
    Given I am at the home page
    And I am not logged in
    When I click the "Offer something" button
    Then I should be redirected to the login page
    And I should see a warning notification that says "You need to log in to offer something"

  Scenario: Trying to create a new item offer without title
    Given I am at the home page
    And I am logged in
    When I click the "Request something" button
    And I click the "Save offer" button
    Then I should stay on the page "Create a new offer"
    And I should see an error message "You must provide a title for your offer" below the "Title" textfield
