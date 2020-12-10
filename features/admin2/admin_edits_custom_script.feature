@javascript
Feature: Admin edits custom script page

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can edit google analytics
    When I go to the custom script admin page
     And I should see disabled "community_custom_head_script" input
