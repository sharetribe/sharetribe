Feature: User views dashboard
  In order to read stuff about Sharetribe
  As a user
  I want to be able to view the dashboard
  
  @no_subdomain
  @javascript
  Scenario: User views dashboard
    Given I am on the home page
    Then I should see "Create a marketplace"
  
  @no_subdomain
  @javascript
  Scenario: User changes dashboard language
    Given I am on the home page
    # These steps temporarily removed since capybara does not seem to
    # work with the jQuery UI select menu component.
    # When I select "Suomi" from "locale"
    # Then I should see "OMA VERKKOTORI"

  
