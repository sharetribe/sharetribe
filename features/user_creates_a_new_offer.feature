Feature: User creates a new offer
  In order to get reciprocal value or to help others
  As a person who has an item, is able to do a favor, or owns a transport
  I want to be able to offer that item, favor, or transport to the other users
  
  Scenario: Creating a new item offer successfully
    Given I am logged in
    And I am on the home page
    When I follow "Offer something"
    And I fill in "listing_title" with "My offer"
    And I fill in "listing_description" with "My description"
    And I press "Save offer"
    Then I should see "Offer: My offer" within "h1"
    And I should see "Offer created successfully" within "#notifications"
