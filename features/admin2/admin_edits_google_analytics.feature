Feature: Admin edits google analytics page

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can edit google analytics
    When I go to the google analytics admin page
     And I fill in "community_google_analytics_key" with "google id"
    Then I press submit
     And I refresh the page
     And I should see "google id" in the "community_google_analytics_key" input
