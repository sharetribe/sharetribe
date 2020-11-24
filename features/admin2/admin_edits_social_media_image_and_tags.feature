Feature: Admin edits social media image and tags

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"
    And I am on the social media image and tags admin page

  Scenario: Admin adds title and description for social media
  When I fill in "community_community_customizations_attributes_0_social_media_title" with "Custom title"
   And I fill in "community_community_customizations_attributes_3_social_media_description" with "Custom description"
   And I attach the file "spec/fixtures/Australian_painted_lady.jpg" to "community_social_logo_attributes_image"
  Then I press submit
   And I refresh the page
  Then I should see "Custom title" in the "community_community_customizations_attributes_0_social_media_title" input
   And I should see "Custom description" in the "community_community_customizations_attributes_3_social_media_description" input
   And I should see "Australian_painted_lady.jpg"
