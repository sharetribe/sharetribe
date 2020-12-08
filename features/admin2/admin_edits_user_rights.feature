@javascript
Feature: Admin edits user rights page

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can set only users verified by admins to post listings
    When I go to the admin2 user rights community "test"
    And I check "Allow only users verified by admins to post listings"
    Then I follow "Open in editor"
    And I change the contents of "verification_to_post_listings_info_content" to "Verification info"
    And I click save on the editor
    Then I check "Allow only users verified by admins to post listings"
    And I press submit
    Then I am logged in as "kassi_testperson2"
    When I follow "Post a new listing"
    Then I should see "Verification info"
    When "kassi_testperson2" is authorized to post a new listing
    And I follow "Post a new listing"
    Then I should see "Select category"
