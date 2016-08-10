Feature: Admin configures maps

  In order to use Google Maps APIs and make it possible for users to find listings by location
  As an admin
  I want to configure Google Maps API key

  Background:
    Given there are following users:
      | person            | given_name | family_name | email               | membership_created_at     |
      | manager           | matti      | manager     | manager@example.com | 2014-03-01 00:12:35 +0200 |
      | kassi_testperson1 | john       | doe         | test2@example.com   | 2013-03-01 00:12:35 +0200 |
      | kassi_testperson2 | jane       | doe         | test1@example.com   | 2012-03-01 00:00:00 +0200 |
    And I am logged in as "manager"
    And "manager" has admin rights in community "test"
    And I am on the maps admin page

  Scenario: Admin adds a google maps api key
  When I add "fookey" to the Google Maps API key field
  And I press submit
  And I refresh the page
  Then I should see "fookey" in the Google Maps API key field
