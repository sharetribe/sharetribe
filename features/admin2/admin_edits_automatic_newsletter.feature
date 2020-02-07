@javascript
Feature: Admin edits automatic newsletter page

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can not edit transaction auto-completion
    When I go to the admin2 configure transactions community "test"
    And I fill in "community_automatic_confirmation_after_days" with "99"
    Then I press submit
    And I should see "Please enter a value less than or equal to 85"

  Scenario: Admin user can edit transaction auto-completion
    When I go to the admin2 configure transactions community "test"
    And I fill in "community_automatic_confirmation_after_days" with "55"
    And I check "community_transaction_agreement_in_use"
    Then I press submit
    And I refresh the page
    And the "community_automatic_confirmation_after_days" field should contain "55"
    And the "community_transaction_agreement_in_use" checkbox should be checked

