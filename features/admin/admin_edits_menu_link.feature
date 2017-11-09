@javascript
Feature: Admin edits menu link

  Background:
    Given "kassi_testperson1" has admin rights in community "test"

    And there is a menu link
    And the title is "Blog link" and the URL is "http://blog.sharetribe.com/" with locale "en" for that menu link
    And the title is "Verkkopäiväkirja" and the URL is "http://blog.sharetribe.com/" with locale "fi" for that menu link

    And there is a menu link
    And the title is "Homepage link" and the URL is "http://sharetribe.com/" with locale "en" for that menu link
    And the title is "Kotisivu" and the URL is "http://sharetribe.com/" with locale "fi" for that menu link

    And I am logged in as "kassi_testperson1"
    And I am on the top bar admin page

  Scenario: Admin edits menu link
    And I change field "Blog link" to "Sharetribe Blog"
    And I change field "Verkkopäiväkirja" to "Sharetriben blogi"
    And I change field "Homepage link" to "Sharetribe Homepage"
    And I change field "Kotisivu" to "Sharetriben Kotisivu"
    And I press submit
    Then I should see "Details updated"
    When I open the menu
    Then I should see "Sharetribe Blog" on the menu
    Then I should see "Sharetribe Homepage" on the menu

  Scenario: Admin edits menu link order
    When I click up for menu link "Homepage link"
    And I press submit
    Then I should see "Details updated"
    When I open the menu
    Then I should see "Blog link" on the menu
    And I should see "Homepage link" on the menu
    And I should see "Homepage link" before "Blog link"

  Scenario: Admin removes menu link
    When I open the menu
    Then I should see "Blog link" on the menu

    When I remove menu link with title "Blog link"
    And I press submit
    Then I should see "Details updated"

    When I open the menu
    Then I should not see "Blog link" on the menu

  Scenario: Admin edits menu link and tries to overfill url, title
    When I fill in menu link field "url" with locale "en" with "300" count of symbols
    When I fill in menu link field "title" with locale "en" with "300" count of symbols
    And I press submit
    Then I should see "255" count of symbols in the "url" menu link field with locale "en"
    Then I should see "255" count of symbols in the "title" menu link field with locale "en"
