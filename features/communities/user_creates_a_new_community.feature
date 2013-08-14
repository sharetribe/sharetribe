Feature: User creates a new community
  In order to enable members of my community to share their assets with each other
  As a community admin
  I want to be able to create a new community
  
  # @javascript 
  # @no_subdomain
  # Scenario: Existing logged in user creates a new free non-profit community
  #   Given I am logged in as "kassi_testperson1"
  #   And I am on the home page
  #   When I follow "GET STARTED NOW!"
  #   And I follow "Association"
  #   #And I follow "Create for free"
  #   # jQuery UI styling of the dropdown menu seems to prevent 
  #   # capybara from selecting the correct locale, so instead
  #   # using a dirty workaround.
  #   #
  #   #And I select "English" from "community_locale"  
  #   And I go to new tribe in English
  #   And I fill in "community_name" with "Test tribe"
  #   And I fill in "community_domain" with "testtribe"
  #   And I fill in "community_address" with "Otaniemi"
  #   And I check "community_terms"
  #   And wait for 2 seconds
  #   And I press "Create your tribe"
  #   Then I should see "Done!"
  #   When I follow "Go to your tribe"
  #   Then I should see "Lend, sell, help, share"
  #   And community "testtribe" should not require invite to join
  # 
  # @no_subdomain
  # @javascript
  # Scenario: Existing user creates a new free for-profit community
  #   Given I am logged in as "kassi_testperson1"
  #   And I am on the home page
  #   When I follow "GET STARTED NOW!"
  #   And I follow "Company"
  #   And I fill in "email" with "test@mycompany.com"
  #   And I press "Continue"
  #   And wait for 1 second
  #   Then I should see "Please confirm your email address" 
  #   And "test@mycompany.com" should receive an email
  #   Then I press "Resend confirmation instructions"
  #   And wait for 1 second
  #   Then I should see "Please confirm your email address"
  #   And "test@mycompany.com" should have 2 emails
  #   When I open the email
  #   And I follow "confirmation" in the email
  #   Then I should see "Create a new tribe in a minute"
  #   #And I select "English" from "community_locale"
  #   And I go to new tribe in English # a hack because normal select doesn't work because UI styling
  #   And I fill in "community_name" with "Corporate tribe"
  #   And I fill in "community_domain" with "corporation_x"
  #   And I fill in "community_address" with "New York"
  #   # because terms are not already accepted (because old account might have different terms)
  #   And I should see "I accept the terms of use"
  #   And I check "community_terms"
  #   And I check "community_join_with_invite_only"
  #   And wait for 2 seconds
  #   And I press "Create your tribe"
  #   Then I should see "Done!"
  #   And community "corporation_x" should require invite to join
  # 
  # @javascript
  # @www_subdomain
  # Scenario: New user signs up and creates a new non-profit community
  #   Given I am not logged in
  #   And I am on the home page
  #   When I follow "GET STARTED NOW!"
  #   And I follow "Association"
  #   And I fill in "Your email address" with "test@example.com"
  #   And I fill in "Pick a username" with random username
  #   And I fill in "Your given name" with "Testmanno"
  #   And I fill in "Your family name" with "Namez"
  #   And I fill in "Pick a password" with "test"
  #   And I fill in "Confirm your password" with "test"
  #   And I check "person_terms"
  #   And I press "Create account"
  #   And wait for 1 second
  #   Then "test@example.com" should receive an email
  #   And I should see "Please confirm your email address"
  # 
  #   # make sure that another try doesn't let the user through without confirmation either
  #   When I follow "header_home_link"
  #   And I follow "GET STARTED NOW!"
  #   And I follow "Association"
  #   Then I should see "Please confirm your email address"
  # 
  #   # try again asking the confirmation mail
  #   When I press "Resend confirmation instructions"
  #   And wait for 1 second
  #   Then I should see "You will soon receive an email with a link that you need to click to confirm the email address you entered"
  #   And "test@example.com" should have 2 emails
  # 
  #   # confirm the address
  #   When I open the email
  #   And I click the first link in the email
  #   Then I should see "Your account was successfully confirmed"
  #   # And I select "English" from "community_locale"
  #   And I go to new tribe in English # a hack because normal select doesn't work because UI styling
  #   And I fill in "community_name" with "Test tribe"
  #   And I fill in "community_domain" with "testtribe"
  #   And I fill in "community_address" with "Otaniemi"
  #   # because terms are already accepted when registering new account
  #   And I should not see "I accept the terms of use"
  #   And wait for 2 seconds
  #   And I press "Create your tribe"
  #   Then I should see "Done!"
  #   When I follow "Go to your tribe"
  #   Then I should see "Lend, sell, help, share"
  #   And community "testtribe" should not require invite to join
  # 
  # 
  # @no_subdomain
  # @javascript
  # Scenario: Existing user tries to create a for-profit community and sign up with an email that is already in use in another organization
  #   Given I am logged in as "kassi_testperson1"
  #   And there is an existing community with "@mycompany.com" in allowed emails and with slogan "Hey hey my my"
  #   And I am on the home page
  #   When I follow "GET STARTED NOW!"
  #   And I follow "Company"
  #   And I fill in "email" with "test@mycompany.com"
  #   And I press "Continue"
  #   Then I should see "There already exists a tribe for this company."
  #   When I follow "here"
  #   # TODO Test browser crashes here saying "the connection to the server
  #   # was reset when the page was loading" - in development everything works great.
  #   # Then I should see "Hey hey my my"
  # 
  # @no_subdomain
  # @javascript
  # Scenario: New user tries to create a for-profit community and sign up with an email that is already use in another organization
  #   Given there is an existing community with "@mycompany.com" in allowed emails and with slogan "Hey hey my my"
  #   And I am on the home page
  #   When I follow "GET STARTED NOW!"
  #   And I follow "Company"
  #   And I fill in "Your company email address" with "test@mycompany.com"
  #   And I press "Create account"
  #   Then I should see "There already exists a tribe for this company"
  #   When I follow "here"
  #   Then I should see "Hey hey my my"
  # 
  # @no_subdomain
  # @javascript
  # Scenario: Existing logged in user tries to create a new community with insufficient information
  #   Given I am logged in as "kassi_testperson1"
  #   And I am on the home page
  #   When I follow "GET STARTED NOW!"
  #   And I follow "Association"
  #   #And I select "English" from "community_locale"  
  #   And I go to new tribe in English # a hack because normal select doesn't work because UI styling
  #   And I fill in "community_name" with "S"
  #   And I fill in "community_domain" with "test"
  #   And I fill in "community_address" with "dsfdsfdsfdsfdsfdssd"
  #   And wait for 2 seconds
  #   And I press "Create your tribe"
  #   Then I should not see "Done!"
  #   And I should see "This field is required"
  # 
  # @no_subdomain
  # @javascript
  # Scenario: Existing logged in user creates an invite-only community
  #   Given I am logged in as "kassi_testperson1"
  #   And I am on the home page
  #   When I follow "GET STARTED NOW!"
  #   And I follow "Association"
  #   And I go to new tribe in English
  #   And I fill in "community_name" with "Test tribe"
  #   And I fill in "community_domain" with "testtribe"
  #   And I fill in "community_address" with "Otaniemi"
  #   And I check "community_terms"
  #   And I check "community_join_with_invite_only"
  #   And wait for 2 seconds
  #   And I press "Create your tribe"
  #   Then I should see "Done!"
  #   And community "testtribe" should require invite to join


