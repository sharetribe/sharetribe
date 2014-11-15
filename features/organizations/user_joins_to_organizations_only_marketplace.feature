Feature: User joins to an organizations only community
  

  @javascript
  Scenario: user creates account
    Given community "test" allows only organizations
    And I am not logged in
    And I signup as an organization "company" with name "Company Ltd"
    Then I should see "Please confirm your email"
    When I confirm my email address
    Then there should be an organization account "company"
    And I should see "Company Ltd" as logged in user