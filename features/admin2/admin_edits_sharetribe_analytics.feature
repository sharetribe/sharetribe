Feature: Admin edits sharetribe analytics page

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can edit sharetribe analytics
    When I go to the sharetribe analytics admin page
     And I check "community_end_user_analytics"
    Then I press submit
     And I refresh the page
     And the "community_end_user_analytics" checkbox should be checked
