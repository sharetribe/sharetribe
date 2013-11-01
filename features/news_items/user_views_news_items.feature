Feature: User views news items
  
  # @javascript
  # Scenario: User views homepage news items
  #   Given I am logged in as "kassi_testperson2"
  #   And I am on the home page
  #   And I should not see "Add an article"
  #   And I should not see "More news"
  #   And I should not see "No news"
  #   When news are enabled in community "test"
  #   And I am on the home page
  #   Then I should see "No news"
  #   And I should not see "Add an article"
  #   And I should not see "More news"
  #   When anyone can add news items in community "test"
  #   And I am on the home page
  #   Then I should see "Add an article"
  #   And I should not see "More news"
  #   When there are "3" news items in community "test"
  #   And I am on the home page
  #   Then I should see "More news"
  # 
  # @javascript
  # Scenario: User views info page news items
  #   Given I am on the home page
  #   When I follow "global-navi-about"
  #   Then I should not see "News"
  #   When news are enabled in community "test"
  #   And I am on the infos page
  #   And I follow "News"
  #   Then I should see "Latest news from"
  #   And I should not see "Add an article"
  #   And I should not see "A new event in our community"
  #   And I should see "No news"
  #   When there are "1" news items in community "test"
  #   And I am on the news page
  #   Then I should see "A new event in our community"
  #   And I should not see "Add an article"
  #   When anyone can add news items in community "test"
  #   And I am on the infos page
  #   And I follow "News"
  #   Then I should see "Add an article"