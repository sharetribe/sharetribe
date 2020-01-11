Feature: Admin edits profile page meta

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"
    And I am on the seo profile meta admin page

  Scenario: Admin adds title and description profile page meta
  When I fill in "community_community_customizations_attributes_0_profile_meta_title" with "Custom title profile tag"
   And I fill in "community_community_customizations_attributes_2_profile_meta_description" with "Custom description profile tag"
  Then I press submit
   And I refresh the page
  Then I should see "Custom title profile tag" in the "community_community_customizations_attributes_0_profile_meta_title" input
   And I should see "Custom description profile tag" in the "community_community_customizations_attributes_2_profile_meta_description" input
