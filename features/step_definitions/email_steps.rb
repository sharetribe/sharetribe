# Commonly used email steps
#
# The provided methods are:
#
# last_email_address
# reset_mailer
# open_last_email
# visit_in_email
# unread_emails_for
# mailbox_for
# current_email
# open_email
# read_emails_for
# find_email
#
# General form for email scenarios are:
#   - clear the email queue (done automatically by email_spec)
#   - execute steps that sends an email
#   - check the user received an/no/[0-9] emails
#   - open the email
#   - inspect the email contents
#   - interact with the email (e.g. click links)
#
# The Cucumber steps below are setup in this order.

Given /^there are following emails:$/ do |emails_table|
  # Clean up old emails first
  emails_table.hashes.each do |hash|
    person = Person.find_by(username: hash[:person])
    person.emails.each { |email| email.destroy }
  end

  # Create new emails
  emails_table.hashes.each do |hash|
    person = Person.find_by(username: hash[:person])
    @hash_email = FactoryGirl.create(:email, :person => person)

    attributes_to_update = hash.except('person')
    @hash_email.update_attributes(attributes_to_update) unless attributes_to_update.empty?
    @hash_email

    # Save
    person.emails << @hash_email
    person.save!
  end
end

When /^I confirm my email address$/ do
  steps %Q{
    Then I should receive 1 email
    When I open the email
    And I click the first link in the email
    Then I should have 2 emails
    And I should see "The email you entered is now confirmed"
  }
end

When /^I confirm email address "(.*?)"$/ do |email|
  steps %Q{
    Then "#{email}" should receive 1 email
    When "#{email}" open the email
    And I click the first link in the email
    And I should see "The email you entered is now confirmed"
  }
end

module EmailHelpers
  def current_email_address
    # Replace with your a way to find your current email. e.g @current_user.email
    # last_email_address will return the last email address used by email spec to find an email.
    # Note that last_email_address will be reset after each Scenario.
    last_email_address || (@logged_in_user && @logged_in_user.confirmed_notification_email_addresses.last) || Thread.current[:latest_used_random_email] || "example@example.com"
  end

  def open_email_for_current_user
    open_email_for(current_email_address)
  end

  def email_count
    mailbox_for(current_email_address).size
  end
end

World(EmailHelpers)

#
# Reset the e-mail queue within a scenario.
# This is done automatically before each scenario.
#

Given /^(?:a clear email queue|no emails have been sent)$/ do
  reset_mailer
end

#
# Check how many emails have been sent/received
#

Then /^(?:I|they|"([^"]*?)") should receive (an|no|\d+) emails?$/ do |address, amount|
  steps %Q{
    When the system processes jobs
  }
  expect(unread_emails_for(address).size).to eq(parse_email_count(amount))
end

Then /^(?:I|they|"([^"]*?)") should have (an|no|\d+) emails?$/ do |address, amount|
  steps %Q{
    When the system processes jobs
  }
  expect(mailbox_for(address).size).to eq(parse_email_count(amount))
end

Then /^(?:I|they|"([^"]*?)") should receive (an|no|\d+) emails? with subject "([^"]*?)"$/ do |address, amount, subject|
  steps %Q{
    When the system processes jobs
  }
  expect(unread_emails_for(address).select { |m| m.subject =~ Regexp.new(Regexp.escape(subject)) }.size).to eq(parse_email_count(amount))
end

Then /^(?:I|they|"([^"]*?)") should receive (an|no|\d+) emails? with subject \/([^"]*?)\/$/ do |address, amount, subject|
  steps %Q{
    When the system processes jobs
  }
  expect(unread_emails_for(address).select { |m| m.subject =~ Regexp.new(subject) }.size).to eq(parse_email_count(amount))
end

Then /^(?:I|they|"([^"]*?)") should receive an email with the following body:$/ do |address, expected_body|
  steps %Q{
    When the system processes jobs
  }
  open_email(address, :with_text => expected_body)
end

#
# Accessing emails
#

# Opens the most recently received email
When /^(?:I|they|"([^"]*?)") opens? the email$/ do |address|
  open_email(address)
end

When /^(?:I|they|"([^"]*?)") opens? the email with subject "([^"]*?)"$/ do |address, subject|
  open_email(address, :with_subject => subject)
end

When /^(?:I|they|"([^"]*?)") opens? the email with subject \/([^"]*?)\/$/ do |address, subject|
  open_email(address, :with_subject => Regexp.new(subject))
end

When /^(?:I|they|"([^"]*?)") opens? the email with text "([^"]*?)"$/ do |address, text|
  open_email(address, :with_text => text)
end

When /^(?:I|they|"([^"]*?)") opens? the email with text \/([^"]*?)\/$/ do |address, text|
  open_email(address, :with_text => Regexp.new(text))
end

#
# Inspect the Email Contents
#

Then /^(?:I|they) should see "([^"]*?)" in the email subject$/ do |text|
  expect(current_email).to have_subject(text)
end

Then /^(?:I|they) should see \/([^"]*?)\/ in the email subject$/ do |text|
  expect(current_email).to have_subject(Regexp.new(text))
end

Then /^(?:I|they) should see "([^"]*?)" in the email body$/ do |text|
  expect(current_email.default_part_body.to_s).to include(text)
end

Then /^(?:I|they) should see \/([^"]*?)\/ in the email body$/ do |text|
  expect(current_email.default_part_body.to_s).to match(Regexp.new(text))
end

Then /^(?:I|they) should see the email delivered from "([^"]*?)"$/ do |text|
  expect(current_email).to be_delivered_from(text)
end

Then /^(?:I|they) should see "([^\"]*)" in the email "([^"]*?)" header$/ do |text, name|
  expect(current_email).to have_header(name, text)
end

Then /^(?:I|they) should see \/([^\"]*)\/ in the email "([^"]*?)" header$/ do |text, name|
  expect(current_email).to have_header(name, Regexp.new(text))
end

Then /^I should see it is a multi\-part email$/ do
    expect(current_email).to be_multipart
end

Then /^(?:I|they) should see "([^"]*?)" in the email html part body$/ do |text|
    expect(current_email.html_part.body.to_s).to include(text)
end

Then /^(?:I|they) should see "([^"]*?)" in the email text part body$/ do |text|
    expect(current_email.text_part.body.to_s).to include(text)
end

#
# Inspect the Email Attachments
#

Then /^(?:I|they) should see (an|no|\d+) attachments? with the email$/ do |amount|
  expect(current_email_attachments.size).to eq(parse_email_count(amount))
end

Then /^there should be (an|no|\d+) attachments? named "([^"]*?)"$/ do |amount, filename|
  expect(current_email_attachments.select { |a| a.filename == filename }.size).to eq(parse_email_count(amount))
end

Then /^attachment (\d+) should be named "([^"]*?)"$/ do |index, filename|
  expect(current_email_attachments[(index.to_i - 1)].filename).to eq(filename)
end

Then /^there should be (an|no|\d+) attachments? of type "([^"]*?)"$/ do |amount, content_type|
  expect(current_email_attachments.select { |a| a.content_type.include?(content_type) }.size).to eq(parse_email_count(amount))
end

Then /^attachment (\d+) should be of type "([^"]*?)"$/ do |index, content_type|
  expect(current_email_attachments[(index.to_i - 1)].content_type).to include(content_type)
end

Then /^all attachments should not be blank$/ do
  current_email_attachments.each do |attachment|
    expect(attachment.read.size).not_to eq(0)
  end
end

Then /^show me a list of email attachments$/ do
  EmailSpec::EmailViewer::save_and_open_email_attachments_list(current_email)
end

#
# Interact with Email Contents
#

When /^(?:I|they) follow "([^"]*?)" in the email$/ do |link|
  visit_in_email(link)
end

When /^(?:I|they) click the first link in the email$/ do
  click_first_link_in_email
end

#
# Debugging
# These only work with Rails and OSx ATM since EmailViewer uses RAILS_ROOT and OSx's 'open' command.
# Patches accepted. ;)
#

Then /^save and open current email$/ do
  EmailSpec::EmailViewer::save_and_open_email(current_email)
end

Then /^save and open all text emails$/ do
  EmailSpec::EmailViewer::save_and_open_all_text_emails
end

Then /^save and open all html emails$/ do
  EmailSpec::EmailViewer::save_and_open_all_html_emails
end

Then /^save and open all raw emails$/ do
  EmailSpec::EmailViewer::save_and_open_all_raw_emails
end
