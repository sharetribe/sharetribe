# encoding: UTF-8

When(/^I pay with Osuuspankki$/) do
  steps %Q{
    When I click Osuuspankki logo
    And I fill in "id" with "123456"
    And I fill in "pw" with "7890"
    And I press "Jatka"
    And I press "Jatka"
    And I press "Hyväksy"
    Then I should see "Maksu maksettu ajantasamaksuna"
    When I follow "Palaa palveluntarjoajan sivulle"
  }
end

When(/^I pay by bill$/) do
  steps %Q{
    When I click Tilisiirto logo
    Then I should see "Testi Pankki"
    When I follow "tästä takaisin kauppiaan sivustolle"
  }
end
