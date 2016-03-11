# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

module FillInHelpers
  def fill_in_first(locator, options={})
    # Highly inspired by Capybara's fill_in implementation
    # https://github.com/jnicklas/capybara/blob/80befdad73c791eeaea50a7cbe23f04a445a24bc/lib/capybara/node/actions.rb#L50
    raise "Must pass a hash containing 'with'" if not options.is_a?(Hash) or not options.has_key?(:with)
    with = options.delete(:with)
    first(:fillable_field, locator, options).set(with)
  end

  def fill_in_nth(locator, n, options={})
    # Highly inspired by Capybara's fill_in implementation
    # https://github.com/jnicklas/capybara/blob/80befdad73c791eeaea50a7cbe23f04a445a24bc/lib/capybara/node/actions.rb#L50
    raise "Must pass a hash containing 'with'" if not options.is_a?(Hash) or not options.has_key?(:with)
    with = options.delete(:with)
    results = all(:fillable_field, locator, options)
    if results.size >= n
      results[n - 1].set(with)
    end
  end
end
World(FillInHelpers)

module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end
World(WithinHelpers)

module FindHelpers
  def find_field_with_value(value)
    matches = all(:xpath, "//input[@value=\"#{value}\"]")

    exact_match = if matches.length == 0
      throw "Couldn't find field with value '#{value}'"
    elsif matches.length > 1
      throw "Ambiguous match, found #{matches.length} fields with value '#{value}'"
    else
      matches.first
    end
  end
end
World(FindHelpers)

Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )go to (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )press "([^"]*)"(?: within "([^"]*)")?$/ do |button, selector|
  with_scope(selector) do
    click_button(button)
  end
end

When /^(?:|I )press submit(?: within "([^"]*)")?$/ do |selector|
  with_scope(selector) do
    find("[type=submit]").click
  end
end

When /^(?:|I )follow "([^"]*)"(?: within "([^"]*)")?$/ do |link, selector|
  with_scope(selector) do
    click_link(link)
  end
end

When(/^I follow the first "(.*?)"$/) do |link|
  first(:link, link).click
end

When /^I remove the focus"?$/ do
  page.execute_script("$('input').blur();")
end

When /^(?:|I )fill in "([^"]*)" with "([^"]*)"(?: within "([^"]*)")?$/ do |field, value, selector|
  with_scope(selector) do
    fill_in(field, :with => value)
  end
end

When /^(?:|I )fill in (first|second|third) "([^"]*)" with "([^"]*)"(?: within "([^"]*)")?$/ do |ordinal, field, value, selector|
  nums = {"first" => 1, "second" => 2, "third" => 3}
  n = nums[ordinal]

  with_scope(selector) do
    fill_in_nth(field, n, :with => value)
  end
end

When(/^I send keys "(.*?)" to form field "([^"]*)"$/) do |keys, field|
  find_field(field).native.send_keys "#{keys}"
end

When /^(?:|I )wait for (\d+) seconds?$/ do |arg1|
  sleep Integer(arg1)
end

When /^(?:|I )fill in "([^"]*)" for "([^"]*)"(?: within "([^"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    fill_in(field, :with => value)
  end
end

# Use this to fill in an entire form with data from a table. Example:
#
#   When I fill in the following:
#     | Account Number | 5002       |
#     | Expiry date    | 2009-11-01 |
#     | Note           | Nice guy   |
#     | Wants Email?   |            |
#
# TODO: Add support for checkbox, select og option
# based on naming conventions.
#
When /^(?:|I )fill in the following(?: within "([^"]*)")?:$/ do |selector, fields|
  with_scope(selector) do
    fields.rows_hash.each do |name, value|
      When %{I fill in "#{name}" with "#{value}"}
    end
  end
end

When /^(?:|I )select "([^"]*)" from "([^"]*)"(?: within "([^"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    select(value, :from => field)
  end
end

When /^(?:|I )check "([^"]*)"(?: within "([^"]*)")?$/ do |field, selector|
  with_scope(selector) do
    check(field)
  end
end

When /^(?:|I )uncheck "([^"]*)"(?: within "([^"]*)")?$/ do |field, selector|
  with_scope(selector) do
    uncheck(field)
  end
end

When /^(?:|I )choose "([^"]*)"(?: within "([^"]*)")?$/ do |field, selector|
  with_scope(selector) do
    choose(field)
  end
end

When /^(?:|I )attach the file "([^"]*)" to "([^"]*)"(?: within "([^"]*)")?$/ do |path, field, selector|
  with_scope(selector) do
    attach_file(field, path)
  end
end

Then /^(?:|I )should see JSON:$/ do |expected_json|
  require 'json'
  expected = JSON.pretty_generate(JSON.parse(expected_json))
  actual   = JSON.pretty_generate(JSON.parse(response.body))
  expect(expected).to eq(actual)
end

Then /^(?:|I )should see "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    expect(page).to have_content(text)
  end
end

Then /^(?:|I )should see \/([^\/]*)\/(?: within "([^"]*)")?$/ do |regexp, selector|
  regexp = Regexp.new(regexp)
  with_scope(selector) do
    expect(page).to have_xpath('//*', :text => regexp)
  end
end

Then /^I should see "([^"]*)" in the "([^"]*)" input$/ do |content, field|
  expect(find_field(field).value).to eq(content)
end

Then /^(?:|I )should not see "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    expect(page).to have_no_content(text)
  end
end

Then /^I should see dropdown field with label "([^"]*)"$/ do |label|
  find_field(label).tag_name == "select"
end

Then /^(?:|I )should not see \/([^\/]*)\/(?: within "([^"]*)")?$/ do |regexp, selector|
  regexp = Regexp.new(regexp)
  with_scope(selector) do
    expect(page).to have_no_xpath('//*', :text => regexp)
  end
end

Then /^the "([^"]*)" field(?: within "([^"]*)")? should contain "([^"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    expect(field_value).to match(/#{value}/)
  end
end

Then /^the "([^"]*)" field(?: within "([^"]*)")? should not contain "([^"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    expect(field_value).not_to match(/#{value}/)
  end
end

Then /^the "([^"]*)" checkbox(?: within "([^"]*)")? should be checked$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
    expect(field_checked).to be_truthy
  end
end

Then /^the "([^"]*)" checkbox(?: within "([^"]*)")? should not be checked$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
    expect(field_checked).to be_falsey
  end
end

Then /^(?:|I )should be on (URL )?(.+)$/ do |match_url, page|
  match_url = match_url == "URL"

  if match_url
    url = URI.parse(current_url)
    expect(url.to_s).to eq(page)
  elsif current_path.respond_to? :should
    current_path = URI.parse(current_url).path
    expect(current_path).to eq(path_to(page))
  else
    assert_equal path_to(page), current_path
  end
end

Then /^(?:|I )should have the following query string:$/ do |expected_pairs|
  query = URI.parse(current_url).query
  actual_params = query ? CGI.parse(query) : {}
  expected_params = {}
  expected_pairs.rows_hash.each_pair{|k,v| expected_params[k] = v.split(',')}

  expect(actual_params).to eq(expected_params)
end

# This is a workaround for PhantomJS, which doesn't (or actually WebDriver) support confirm dialogs.
# Use this keyword BEFORE the confirmation dialog appears
Given /^I will(?:| (not)) confirm all following confirmation dialogs in this page if I am running PhantomJS$/ do |do_not_confirm|
  confirm = do_not_confirm != "not"
  if ENV['PHANTOMJS'] then
    page.execute_script("window.__original_confirm = window.confirm; window.confirm = function() { return #{confirm}; };")
  end
end

When /^I confirm alert popup$/ do
  page.driver.browser.switch_to.alert.accept unless ENV['PHANTOMJS']
end

Then /^I should see validation error$/ do
  expect(find("label.error")).to be_visible
end

Then /^I should see (\d+) validation errors$/ do |errors_count|
  errors = all("label.error");
  expect(errors.size).to eql(errors_count.to_i)
  all("label.error").each { |error|
    expect(error).to be_visible
  }
end

Then /^take a screenshot$/ do
  save_screenshot('screenshot.png')
end

Then /^show me the page$/ do
  save_and_open_page
end

When /^I refresh the page$/ do
  visit(current_path)
end

When /^I hover "([^"]*)"$/ do |selector|
  find(selector).hover
end

Then(/^"([^"]*)" should have CSS property "([^"]*)" with value "([^"]*)"$/) do |selector, property, value|
  actual_value = page.evaluate_script("$('#{selector}').css('#{property}')");
  expect(actual_value).to be_eql(value)
end

When(/^I change field "([^"]*)" to "([^"]*)"$/) do |from, to|
  find_field_with_value(from).set(to)
end
