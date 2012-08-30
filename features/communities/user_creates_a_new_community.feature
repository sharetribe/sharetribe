Feature: User creates a new community
  In order to enable members of my community to share their assets with each other
  As a community admin
  I want to be able to create a new community
  
  @no_subdomain
  @javascript
  Scenario: Existing logged in user creates a new free non-profit community
    Given I am logged in as "kassi_testperson1"
    And I am on the home page
    When I follow "GET STARTED NOW!"
    And I follow "Association"
    And I follow "Create for free"
    # jQuery UI styling of the dropdown menu seems to prevent 
    # capybara from selecting the correct locale, so instead
    # using a dirty workaround.
    #
    #And I select "English" from "community_locale"  
    And I go to new tribe in English
    And I fill in "community_name" with "Test tribe"
    And I fill in "community_domain" with "testtribe"
    And I fill in "community_address" with "Otaniemi"
    And I check "community_terms"
    And wait for 2 seconds
    And I press "Create your tribe"
    Then I should see "Done!"
    When I follow "Go to your tribe"
    Then I should see "Lend, help, share"
  
  @no_subdomain
  @javascript
  Scenario: Existing user creates a new free for-profit community
    Given I am logged in as "kassi_testperson1"
    And I am on the home page
    When I follow "GET STARTED NOW!"
    And I follow "Company"
    And I follow "Create for free"
    And I fill in "email" with "test@mycompany.com"
    And I press "Continue"
    #And "test@mycompany.com" should receive an email
    Then I should see "Please confirm your email address"
    #TODO: Test the process after the email address has been confirmed
    #When I open the email
    #And I follow "Confirm my account"

  @no_subdomain
  @javascript
  Scenario: New user signs up and creates a new non-profit community
    Given I am on the home page
    When I follow "GET STARTED NOW!"
    And I follow "Association"
    And I follow "Create for free"
    And I fill in "Your email address" with "test@example.com"
    And I fill in "Pick a username" with random username
    And I fill in "Your given name" with "Testmanno"
    And I fill in "Your family name" with "Namez"
    And I fill in "Pick a password" with "test"
    And I fill in "Confirm your password" with "test"
    And I check "person_terms"
    And I press "Create account"
    #And "test@example.com" should receive an email
    Then I should see "Please confirm your email address"
    When I follow "Home"
    And I follow "GET STARTED NOW!"
    And I follow "Association"
    And I follow "Create for free"
    Then I should see "Please confirm your email address"
    #When I open the email
    #And I follow "Confirm my account"
  
  @no_subdomain
  @javascript
  Scenario: Existing user tries to create a for-profit community and sign up with an email that is already use in another organization
    Given I am logged in as "kassi_testperson1"
    And there is an existing community with "@mycompany.com" in allowed emails
    And I am on the home page
    When I follow "GET STARTED NOW!"
    And I follow "Company"
    And I follow "Create for free"
    And I fill in "email" with "test@mycompany.com"
    Then I should see "There already exists a tribe for this company." within ".error"
    When I follow "here"
    Then I should be on the page of the existing tribe
  
  @no_subdomain
  @javascript
  Scenario: New user tries to create a for-profit community and sign up with an email that is already use in another organization
    Given I am logged in as "kassi_testperson1"
    And I am on the home page
    When I follow "GET STARTED NOW!"
    And I follow "Company"
    And I follow "Create for free"
    And I fill in "Your email address" with "test@example.com"
    And I fill in "Pick a username" with random username
    And I fill in "Your given name" with "Testmanno"
    And I fill in "Your family name" with "Namez"
    And I fill in "Pick a password" with "test"
    And I fill in "Confirm your password" with "test"
    And I check "person_terms"
    And I press "Create account"
    And I fill in "email" with "test@mycompany.com"
  
  @no_subdomain
  @javascript
  Scenario: User creates a premium community
    Given context
    When event
    Then outcome
  
  
  
  
  
  
  
  

  
