@javascript
Feature: Admin edits text instructions with WYWISYG editor

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"
    And I am on the text instructions admin page

  Scenario: Admin user can edit private marketplace homepage content
    Then I should not see "Private marketplace homepage content"
    When community "test" is private
    And I refresh the page
    Then I should see "Private marketplace homepage content"
    When I follow "Edit information"
    And I change the contents of "private_community_homepage_content" to "Private homepage info"
    And I click save on the editor
    Then I should see "Edit information"
    When I refresh the page
    Then I should see "Private homepage info"
    When I log out
    And I go to the homepage
    Then I should see "Private homepage info"

  Scenario: Admin user can edit verification to post listings info content
    Then I should not see "Info text to non-verified users"
    When current community requires users to be verified to post listings
    And I refresh the page
    Then I should see "Info text to non-verified users"
    When I follow "Edit information"
    And I change the contents of "verification_to_post_listings_info_content" to "Verification info"
    And I click save on the editor
    Then I should see "Edit information"
    When I refresh the page
    Then I should see "Verification info"

    When I am logged in as "kassi_testperson2"
    When I follow "Post a new listing"
    Then I should see "Verification info"
    When "kassi_testperson2" is authorized to post a new listing
    And I follow "Post a new listing"
    Then I should see "Select category"

  Scenario: Admin edits signup information
    Then I should see "Signup info"
    When I follow "Edit information"
    And I change the contents of "signup_info_content" to "Custom signup info"
    And I click save on the editor
    Then I should see "Edit information"
    And I should see "Custom signup info"
    When I log out
    And I follow "Log in"
    And I follow "Create a new account"
    Then I should see "Custom signup info"
