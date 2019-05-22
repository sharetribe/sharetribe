Feature: User updates profile information
  In order to change the information the other users see in my profile page
  As a user
  I want to able to update my profile information

  Background:
    Given there are following users:
      | person |
      | kassi_testperson2 |
    And I am logged in as "kassi_testperson2"
    And I am on the profile settings page

  @javascript
  Scenario: Updating profile successfully
    When I fill in "First name" with "Test"
    And I fill in "Last name" with "Dude"
    And I fill in "Location" with "Broadway"
    And mock googlemap location with "Broadway, 41.111, -73.8583"
    And I fill in "Phone number" with "0700-715517"
    And I fill in "About you" with "Some random text about me"
    And I press "Save information"
    Then I should see "Information updated" within ".flash-notifications"
    And the "First name" field should contain "Test"
    And the "Last name" field should contain "Dude"
    And the "Location" field should contain "Broadway"
    And I should not see my username

  @javascript
  Scenario: Updating profile's custom fields successfully
    And there is a required person custom text field "House type" in community "test"
    And there is a required person custom numeric field "Points" in community "test"
    And there is a required person custom date field "Member since" in community "test"
    And there is a required person custom dropdown field "Balcony type" in community "test" with options:
      | en             | fi                   |
      | No balcony     | Ei parveketta        |
      | French balcony | Ranskalainen parveke |
      | Backyard       | Takapiha             |
    And there is a required person custom checkbox field "Language" in community "test" with options:
      | en             | fi                   |
      | English language | englanti           |
      | German language  | saksa              |
      | French language  | ranskalainen       |
    And I am on the profile settings page
    And I fill in "person_custom_fields_0" with "Log Cabin"
    And I fill in "person_custom_fields_1" with "23"
    And I select "2000" from "person[custom_field_values_attributes][][date_value(1i)]"
    And I select "June" from "person[custom_field_values_attributes][][date_value(2i)]"
    And I select "21" from "person[custom_field_values_attributes][][date_value(3i)]"
    And I select "French balcony" from "person_custom_fields_3"
    And I check "English language"
    And I check "French language"
    And I press "Save information"
    Then I should see "Information updated" within ".flash-notifications"
    Then the "person_custom_fields_0" field should contain "Log Cabin"
    And the "person_custom_fields_1" field should contain "23"
    And the "person[custom_field_values_attributes][][date_value(1i)]" field should contain "2000"
    And the "person[custom_field_values_attributes][][date_value(2i)]" field should contain "6"
    And the "person[custom_field_values_attributes][][date_value(3i)]" field should contain "21"
    And I should see "French balcony"
    And the "English language" checkbox should be checked
    And the "German language" checkbox should not be checked
    And the "French language" checkbox should be checked

  @javascript
  Scenario: Profile's custom text field has autolink
    And there is a required public person custom text field "Hobby" in community "test"
    And I am on the profile settings page
    And I fill in "person_custom_fields_0" with "Airplane models www.example.com"
    And I press "Save information"
    Then I should see "Information updated" within ".flash-notifications"
    And I am on my profile page
    Then should see link "www.example.com" to "http://www.example.com"

  @javascript
  Scenario: Updating required profile's custom checkbox field shows error message
    And there is a person custom dropdown field "Balcony type" in community "test" with options:
      | en             | fi                   |
      | No balcony     | Ei parveketta        |
      | French balcony | Ranskalainen parveke |
      | Backyard       | Takapiha             |
    And there is a required person custom checkbox field "Language" in community "test" with options:
      | en             | fi                   |
      | English language | englanti           |
      | German language  | saksa              |
      | French language  | ranskalainen       |
    And I am on the profile settings page
    And I press "Save information"
    Then I should see "This field is required."

