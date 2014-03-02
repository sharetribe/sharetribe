Feature: User is banned from a community
  In order to prevent malicious or spammy users disturbing my marketplace
  As a admin
  I want that banned users can't join the marketplace


  Background:
    Given there are following users: 
      | person            | given_name | family_name   |  
      | spammer           | matti      | malicious     | 
    And user "spammer" is banned in this community
    And I am logged in as "spammer"
  
  
  

  Scenario: Banned user can't join the marketplace
    When I go to front page
    Then I should see a message that I have been banned

  Scenario: Banned user can't create listings
    When I go to new listing page
    Then I should see a message that I have been banned

  Scenario: Banned user can contact admin
    When I go to contact us page
    Then I should be able to send a message to admin
  
  
  
