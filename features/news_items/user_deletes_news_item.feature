Feature: User deletes news item
  
  @javascript
  Scenario: User deletes news item successfully
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
      | kassi_testperson3 |
    And there is news item by "kassi_testperson1"
    And news are enabled in community "test"
    And anyone can add news items in community "test"
    When I follow 
    
  @javascript
  Scenario: Admin deletes news item successfully from news page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
      | kassi_testperson3 |
    And there is news item by "kassi_testperson1"
    And news are enabled in community "test"
    And anyone can add news items in community "test"
    When I follow
  
  
  

  
