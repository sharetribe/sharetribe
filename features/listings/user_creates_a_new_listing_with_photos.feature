@skip_phantomjs
Feature: User creates a new listing with photos

  Background:
    Given I am logged in
    And I am on the new listing page
    And I follow "Items"
    And I follow "Tools" within "#option-groups"
    And I follow "Requesting"
    And I fill in "listing_title" with "Sledgehammer"
    And I fill in "listing_description" with "My description"

  @javascript
  @no-transaction
  Scenario: Creating a new item request with image successfully
    # @no-transaction needed because delayed_paperclip after_save callbacks
    And I attach a valid listing image
    And I press "Save listing"
    Then I should see "Sledgehammer" within "#listing-title"
    And I should see the image I just uploaded

  @javascript
  @no-transaction
  Scenario: Creating a new item request with image successfully
    # @no-transaction needed because delayed_paperclip after_save callbacks
    And I attach a listing image "ds1-1.jpg"
    And I attach a listing image "ds1-2.jpg"
    And I attach a listing image "ds1-3.jpg"
    And I press "Save listing"
    Then I should see listing image "ds1-1.jpg"
    When I click for the next image
    Then I should see listing image "ds1-2.jpg"
    When I click for the next image
    Then I should see listing image "ds1-3.jpg"
    When I click for the next image
    Then I should see listing image "ds1-1.jpg"
    When I click for the previous image
    Then I should see listing image "ds1-3.jpg"