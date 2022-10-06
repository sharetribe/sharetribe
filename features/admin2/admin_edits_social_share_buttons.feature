Feature: Admin edits twitter

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"
    And I am on the social share buttons admin page

  @javascript
  Scenario: Admin can change social share buttons property
    When I choose "community_enable_social_share_buttons_true"
     And I press submit
     And I wait for 1 seconds
     And I refresh the page
    Then the "community_enable_social_share_buttons_true" checkbox should be checked

  @javascript
  Scenario: Admin can not change social share buttons property
    When Community "test" is private
    Then I should not see "community_enable_social_share_buttons_true"