Feature: User sends contact request
  In order to announce that I want more information about Kassi
  As a user
  I want to be able to send a contact request
  
  @no_subdomain
  @javascript
  Scenario: User sends a contact request successfully
    Given I am on the home page
    When I fill in "contact_request_email" with "test@example.com"
    And I press "Send!"
    Then I should see "Thank you!"
  
  
  
  

  
