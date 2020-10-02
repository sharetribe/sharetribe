@javascript
Feature: Admin edit testimonials

  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Requesting"
    And the price of that listing is 11.44 USD

  Scenario: Admin see list of testimonials
    And there is paid transaction with testimonials for a listing with title "Massage" starter "kassi_testperson2"
    When I go to the testimonials admin2 page of community "test"
    When click to testimonial edit link
    Then I should see "Hi from author" within field "provider_comment"
    Then I fill in "provider_comment" with "What is up?"
    Then I press "Save"
    Then click to testimonial edit link
    Then I should see "What is up?"
