Feature: Modify or add organizations
  In order to modify my organizations or add a new one that I also want to represent
  As a user of the service and the admin of the organizations
  I want to be able to see a list of my organizations and be able to modify existing ones and add new if needed
  
  @javascript
  Scenario: adding a new organization
    Given community "test" requires organization membership
    And there is a seller organization "Corporation Example"
    And I am logged in as "kassi_testperson"
    And "kassi_testperson" is an admin of the organization "Corporation Example"
    And "kassi_testperson" is a member of community "test"
        
    When I go to my profile page
    Then I should see "Presented Organizations"
    And I should see "Corporation Example"
    And I should see "Add New Organization"
    When I follow "Add New Organization"
    Then I should see "Create new organization"

    When I press "Create"
    When I fill in "Name" with "My super corporation"
    And I press "Create"
    
    Then I should see "Presented Organizations"
    And I should see "Corporation Example"
    And I should see "My super corporation"

  @javascript
  Scenario: user modifies existing organization
    Given community "test" requires organization membership
    And there is a non-seller organization "Corporation Example"
    And I am logged in as "kassi_testperson"
    And "kassi_testperson" is an admin of the organization "Corporation Example"
    And "kassi_testperson" is a member of community "test"
    
    When I go to my profile page
    Then I should see "Presented Organizations"
    And I should see "Corporation Example"
    And I should see "Edit"
    
    When I follow "Edit" within "#profile-organizations-list"
    Then I should see "Name"
    And I should see "Register As Merchant"
    And I should not see "Organization Address"
    
    When I choose "register_as_merchant"
    Then I should see "Organization Address"
    
    When I fill in "organization_company_id" with "1234567-8"
    And I fill in "organization_email" with "new.corporate.guy@example.com"
    And I fill in "organization_phone_number" with "555-55555555"
    And I fill in "organization_address" with "fancy road 13, 12345, Antarctica"
    And I fill in "organization_website" with "http://www.example.com"
    And I press "Save changes"
    
    Then I should see "Presented Organizations"
    And organization "Corporation Example" should have a merchant_id
    
  
  
  