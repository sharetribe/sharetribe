Feature: User views a single listing
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: User views a listing that he is allowed to see
    Given I am logged in
    And there is favor request with title "Massage" from "kassi_testperson1"
    And I am on the home page
    When I follow "Massage"
    Then I should see "Favor request: Massage"
  
  @javascript
  Scenario: User tries to view a listing restricted viewable to community members without logging in
    Given I am not logged in
    And there is favor request with title "Massage" from "kassi_testperson1"
    And visibility of that listing is "this_community"
    And I am on the home page
    When I go to the listing page
    Then I should see "You must log in to view this content"
  
  @subdomain2
  @javascript
  Scenario: User tries to view a listing from another community
    Given I am not logged in
    And there is favor request with title "Massage" from "kassi_testperson1"
    And I am on the home page
    When I go to the listing page
    Then I should see "This content is not available in this community."
  
  
  
  
  
  
  
