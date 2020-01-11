Feature: Admin edits listing page meta

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"
    And I am on the seo listing meta admin page

  Scenario: Admin adds title and description for listing page meta
  When I fill in "community_community_customizations_attributes_0_listing_meta_title" with "Custom title listing tag"
   And I fill in "community_community_customizations_attributes_2_listing_meta_description" with "Custom description listing tag"
  Then I press submit
   And I refresh the page
  Then I should see "Custom title listing tag" in the "community_community_customizations_attributes_0_listing_meta_title" input
   And I should see "Custom description listing tag" in the "community_community_customizations_attributes_2_listing_meta_description" input
