When /^I click save on the editor$/ do
  find("em", :text => "Save").click
end

Then /^I should not have editor open$/ do
  expect { !current_path.start_with? "/editor/" }.to become_true
end

Then /^I should have editor open$/ do
  expect(page).to have_selector("#mercury_iframe")
end

When(/^I send keys "(.*?)" to editor$/) do |keys|
  page.driver.browser.switch_to.frame 'mercury_iframe'
  find("[data-mercury]", :visible => false).native.send_keys "#{keys}"
  page.driver.browser.switch_to.default_content
end

# This method should be used when there are multiple Mercury-editable
# places on a same view.
When /^(?:|I )(?:change|set) the contents? of "(.*?)" to "(.*?)"$/ do |region_id, content|
  page.driver.browser.switch_to.frame 'mercury_iframe'
  find("##{region_id}", :visible => false)
  page.driver.execute_script <<-JAVASCRIPT
    jQuery(document).find('##{region_id}').html('#{content}');
  JAVASCRIPT
  page.driver.browser.switch_to.default_content
end
