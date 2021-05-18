@javascript
Feature: Admin edits custom script page

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can edit google analytics
    When I go to the custom script admin page
    And I fill in "community_custom_head_script" with "<script>test script</script>"
    Then I press submit
    And I wait for 1 seconds
    And I refresh the page
    And I should see "<script>test script</script>" in the "community_custom_head_script" input
    Then I go to the homepage
    And Page should contain "test script"

  Scenario: Admin user can edit custom css script
    When I go to the custom script admin page
    And I fill in "community_custom_css_script" with "body{color: red;}"
    Then I press submit
    And I wait for 1 seconds
    And I refresh the page
    And I should see "body{color: red;}" in the "community_custom_css_script" input
    Then I go to the homepage
    And Page should contain "body{color: red;}"

  Scenario: Admin user can edit custom body script
    When I go to the custom script admin page
    And I fill in "community_custom_body_script" with "<script>test body script</script>"
    Then I press submit
    And I wait for 1 seconds
    And I refresh the page
    And I should see "<script>test body script</script>" in the "community_custom_body_script" input
    Then I go to the homepage
    And Page should contain "test body script"
