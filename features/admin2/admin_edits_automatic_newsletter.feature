@javascript
Feature: Admin edits automatic newsletter page

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can not edit transaction auto-completion
    When I go to the admin2 configure transactions community "test"
    And I fill in "community_automatic_confirmation_after_days" with "99"
    Then I press submit
    And I wait for 1 seconds
    And I should see "Please enter a value less than or equal to 85"

  Scenario: Admin user can edit transaction auto-completion
    When I go to the admin2 configure transactions community "test"
    And I fill in "community_automatic_confirmation_after_days" with "55"
    And I check "community_transaction_agreement_in_use"
    And I fill in "community_community_customizations_attributes_0_transaction_agreement_label" with "label"
    And I fill in "community_community_customizations_attributes_2_transaction_agreement_content" with "content"
    And I fill in "community_community_customizations_attributes_1_transaction_agreement_label" with "label"
    And I fill in "community_community_customizations_attributes_3_transaction_agreement_content" with "content"
    Then I press submit
    And I wait for 1 seconds
    And I refresh the page
    And the "community_automatic_confirmation_after_days" field should contain "55"
    And the "community_transaction_agreement_in_use" checkbox should be checked

