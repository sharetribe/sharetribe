Feature: User views a single listing
  In order to value
  As a role
  I want feature

  @phantomjs_skip
  @javascript
  @only_without_asi
  Scenario: User views a listing that he is allowed to see
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |    
    And there is favor request with title "Massage" from "kassi_testperson1"
    And I am on the home page
    When I follow "Massage"
    Then I should see "Massage"
    And I should see "No reviews received"
    When I am logged in as "kassi_testperson1"
    And I have "2" testimonials with grade "1"
    And I am on the home page
    And I follow "Massage"
    Then I should see "Feedback"
    And I should see "100%"
    And I should see "(2/2)"
    #And I should see "Add profile picture"
    When I click ".user-menu-toggle"
    When I follow "Settings"
    And I attach a valid image file to "avatar_file"
    And I press "Save information"
    And I go to the home page
    And I follow "Massage"
    Then I should not see "Add profile picture"
  
  @javascript
  Scenario: User tries to view a listing restricted viewable to community members without logging in
    Given I am not logged in
    And there is favor request with title "Massage" from "kassi_testperson1"
    And privacy of that listing is "private"
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
  
  @javascript
  Scenario: User belongs to multiple communities, adds listing in one and sees it in another
    Given I am not logged in
    And there is favor request with title "Massage" from "kassi_testperson1"
    And privacy of that listing is "private"
    And I am on the home page
    When I go to the listing page
    Then I should see "You must log in to view this content"
  
  
  
