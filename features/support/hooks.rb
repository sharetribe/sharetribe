Before('@badge') do
  steps %Q{
    Given there are following users:
       | person | 
       | kassi_testperson1 |
       | kassi_testperson2 |
    And I am logged in as "kassi_testperson1"
    When I go to the badges page of "kassi_testperson1"
    And I should see "Badges" within ".inbox_tab_selected"
    And I should see "Received feedback" within ".inbox_tab_unselected"
  }
end