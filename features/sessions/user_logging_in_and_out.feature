Feature: User logging in and out
  In order to log in and out of Sharetribe
  As a user
  I want to be able to enter username and password and log in to Sharetribe and also log out

  Scenario: logging in successfully
    Given I am not logged in
    And I am on the login page
    When I fill in "main_person_login" with "kassi_testperson1@example.com"
    And I fill in "main_person_password" with "testi"
    And I click "#main_log_in_button"
    Then I should see "Welcome, Kassi!"
    Then I should be logged in

  Scenario: trying to log in with false credentials
    Given I am not logged in
    And I am on the login page
    When I fill in "main_person_login" with "whatever"
    And I fill in "main_person_password" with "certainly_not_the_correct_password"
    And I click "#main_log_in_button"
    Then I should see "Login failed."
    Then I should not be logged in

  @subdomain2
  Scenario: trying to log in without community membership
    Given I am not logged in
    And I am on the login page
    When I fill in "main_person_login" with "kassi_testperson1"
    And I fill in "main_person_password" with "testi"
    And I click "#main_log_in_button"
    Then I should see "Login failed."
    Then I should not be logged in

  Scenario: logging out
    Given I am logged in
    When I log out
    Then I should not be logged in

  Scenario: Seeing my name or username on header after login
    Given I am logged in
    And my given name is "John"
    When I am on the home page
    Then I should see "John"

  Scenario: User logs in with his primary email
    Given I am not logged in
    And I am on the login page
    When I fill in "main_person_login" with "kassi_testperson1@example.com"
    And I fill in "main_person_password" with "testi"
    And I click "#main_log_in_button"
    Then I should see "Welcome, Kassi!"
    Then I should be logged in

  Scenario: User logs in with his additional email
    Given user "kassi_testperson1" has additional email "work.email@example.com"
    And I am not logged in
    And I am on the login page
    When I fill in "main_person_login" with "work.email@example.com"
    And I fill in "main_person_password" with "testi"
    And I click "#main_log_in_button"
    Then I should see "Welcome, Kassi!"
    Then I should be logged in

  Scenario: Marketplace's admin logging in successfully
    Given "kassi_testperson1" has admin rights in community "test"
    Given I am not logged in
    And I am on the login page
    When I fill in "main_person_login" with "kassi_testperson1@example.com"
    And I fill in "main_person_password" with "testi"
    And I click "#main_log_in_button"
    Then I should see "Welcome, Kassi! Would you like to visit your admin panel?"
    Then I should be logged in

