Feature: Admin edits landing page meta

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"
    And I am on the seo landing meta admin page

  Scenario: Admin adds title and description for landing page meta
  When I fill in "community_community_customizations_attributes_0_meta_title" with "Custom title tag"
   And I fill in "community_community_customizations_attributes_2_meta_description" with "Custom description tag"
  Then I press submit
   And I refresh the page
  Then I should see "Custom title tag" in the "community_community_customizations_attributes_0_meta_title" input
   And I should see "Custom description tag" in the "community_community_customizations_attributes_2_meta_description" input
