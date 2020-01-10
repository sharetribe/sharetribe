Feature: Admin edits twitter

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"
    And I am on the social media twitter admin page

  Scenario: Admin add twitter handle
    When I fill in "community_twitter_handle" with "twitterhandle"
     And I press submit
     And I refresh the page
    Then I should see "twitterhandle" in the "community_twitter_handle" input

  Scenario: Admin add twitter handle with @
    When I fill in "community_twitter_handle" with "@twitterhandle"
    And I press submit
    And I refresh the page
    Then I should see "twitterhandle" in the "community_twitter_handle" input
