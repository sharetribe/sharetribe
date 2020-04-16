Feature: Admin edits welcome email

  @javascript
  Scenario: Admin user can edit community details
    Given I am logged in as "kassi_testperson1"
    When I go to the admin2 welcome email community "test"
    And I fill in "community_community_customizations_attributes_0_welcome_email_content" with "Welcome email"
    When I follow "Send a test email to yourself"
    And the system processes jobs
    Then "kassi_testperson1@example.com" should receive an email
    When I open the email
    Then I should see "Welcome email" in the email body
