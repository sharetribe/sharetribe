Feature: User joins an organization
  In order to use a community where I can represent an organization
  As a user and a member of an organization
  I want to be able to join and organization when joining the tribe (actually that's even required)
  
  @javascript
  Scenario: user makes new account and joins existing organization
    Given community "test" requires organization membership
    And there is a seller organization "Corporation Example" with email requirement "@example.corp"
    And I am not logged in
    And I am on the signup page
    When I fill in "person[username]" with random username
    And I fill in "Given name" with "Testmanno"
    And I fill in "Family name" with "Namez"
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with "new.corporate.guy@example.com"
    And I check "person_terms"
    And I press "Create account"
    Then I should see "This community requires every member to represent an organization"
    
    When I select "Corporation Example" from "organization_id" 
    And I fill in "community_membership_email" with "richard@example.com"
    And wait for 1 seconds
    And I press "Join community"
    Then I should see "The selected organization requires your email to be in format: @example"
    When I fill in "community_membership_email" with "richard@example.corp"
    And I check "community_membership_consent"
    And wait for 1 seconds
    And I press "Join community"
    Then I should see "Confirm your email"
    
    When wait for 1 seconds
    Then "richard@example.corp" should receive 1 email
    When I open the email
    And I click the first link in the email
    Then I should have 2 emails
    And I should see "Your account was successfully confirmed"
    And I should see "Post a new listing"
    And Most recently created user should be member of "test" community with status "accepted" and its latest consent accepted
  
  @javascript
  Scenario: user logs in and joins an organization that she creates
    Given there are following users:
      | person | 
      | kassi_testperson3 |
    Given community "test3" requires organization membership
    And I am logged in as "kassi_testperson3"
    When I move to community "test3"
    And I am on the home page
    Then I should see "Join community"
    When I check "community_membership_consent"
    And I press "Join community"
    Then I should see "You need to choose an organization."
    
    When I follow "Create new organization"
    Then I should see "Create new organization"

    When I press "Create"
    Then I should see "This field is required"
    When I fill in "Name" with "My super corporation"
    And I fill in "Allowed Emails" with "@example.com"
    And I press "Create"
    
    Then I should see "Join community"
    When I select "My super corporation" from "organization_id"
    When I fill in "community_membership_email" with "sally@example.com"
    When I check "community_membership_consent"
    And I press "Join community"
    
    Then I should see "Confirm your email"
    
    When wait for 1 seconds
    Then "sally@example.com" should receive 1 email
    When I open the email
    And I click the first link in the email
    Then I should have 2 emails
    And I should see "Your account was successfully confirmed"
    
    Then I should see "Post a new listing"
  
  @javascript
  Scenario: user logs in and creates organization with seller registration
    Given community "test2" requires organization membership
    When I move to community "test2"
    And I am logged in as "kassi_testperson"
    
    When I follow "Create new organization"
    Then I should see "Create new organization"
    
    When I fill in "Name" with "Seller corp"
    And I choose "register_as_merchant"
    And I press "Create"
    Then I should see "You need to fill in all the details"
    When I fill in "organization_company_id" with "1234567-8"
    When I fill in "organization_phone_number" with "555-55555555"
    When I fill in "organization_address" with "fancy road 13, 12345, Antarctica"
    When I fill in "organization_website" with "http://www.example.com"
    And I press "Create"
        
    Then I should see "Join community"
    When I select "Seller corp" from "organization_id" 
    When I check "community_membership_consent"
    And I press "Join community"
    
    Then I should see "Post a new listing"
    And Most recently created organization should have all seller attributes filled
  
