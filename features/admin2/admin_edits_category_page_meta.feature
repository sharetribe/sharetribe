Feature: Admin edits category page meta

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"
    And I am on the seo category meta admin page

  Scenario: Admin adds title and description for category page meta
  When I fill in "community_community_customizations_attributes_0_category_meta_title" with "Custom title category tag"
   And I fill in "community_community_customizations_attributes_2_category_meta_description" with "Custom description category tag"
  Then I press submit
   And I refresh the page
  Then I should see "Custom title category tag" in the "community_community_customizations_attributes_0_category_meta_title" input
   And I should see "Custom description category tag" in the "community_community_customizations_attributes_2_category_meta_description" input
