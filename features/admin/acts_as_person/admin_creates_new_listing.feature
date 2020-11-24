Feature: Admin creates a new listing as another user
  Background:
    Given there are following users:
      | person            |
      | kassi_testperson1 |
      | kassi_testperson2 |
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  @javascript
  Scenario: Creating a new item request without image successfully
    When I go to the profile page of "kassi_testperson2"
    When I follow "Post listing as"
    And I select "Items" from listing type menu
    And I select "Tools" from listing type menu
    And I select "Requesting" from listing type menu
    And I fill in "listing_title" with "Virtual war plane"
    And I fill in "listing_description" with "My description"
    And I press "Post listing"
    Then I should see "Virtual war plane" within "#listing-title"
    And listing with title "Virtual war plane" has author "kassi_testperson2"

