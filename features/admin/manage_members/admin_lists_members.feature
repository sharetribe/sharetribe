Feature: Admin lists members
  
  Background:
    Given there are following users: 
      |person|
      |manager|
      |kassi_testperson1|
      |kassi_testperson2|
    And I am logged in as "manager"
    And "manager" has admin rights in community "test"
    And I am on the manage members admin page

  @javascript
  Scenario: Admin views member count
    Then I should see member count 3
