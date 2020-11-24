Feature: Admin edits search page meta

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"
    And I am on the seo search meta admin page

  Scenario: Admin adds title and description for search page meta
  When I fill in "community_community_customizations_attributes_0_search_meta_title" with "Custom title search tag"
   And I fill in "community_community_customizations_attributes_2_search_meta_description" with "Custom description search tag"
  Then I press submit
   And I refresh the page
  Then I should see "Custom title search tag" in the "community_community_customizations_attributes_0_search_meta_title" input
   And I should see "Custom description search tag" in the "community_community_customizations_attributes_2_search_meta_description" input
