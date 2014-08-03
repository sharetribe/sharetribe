# Cucumber testing do's and don'ts

This document describes Sharetribe's Cucumber testing do's and don'ts. Most of these tips come from [Cucumber Backgrounder](https://github.com/cucumber/cucumber/wiki/Cucumber-Backgrounder), which is a very good introduction to Cucumber. Highly recommended reading.

**A word of warning:** Sharetribe codebase includes a lot of Cucumber code that does not follow these recommendations. We'll clean up them little by little, but the important thing is that you should not use those pieces as a reference.

## Declarative over Imperative

Do **not** write steps in imperative styles, instead write steps in declarative style. Imperative style leads to tight coupling to the implementation of the UI.

A good question to ask yourself when writing a feature clause is: Will this wording need to change if the implementation does?

**Don't**

```gherkin
Given I visit "/login"
When I enter "Bob" in the "user name" field
  And I enter "tester" in the "password" field
  And I press the "login" button
Then I should see the "welcome" page
```

**Do**

```gherkin
When "Bob" logs in
```

## Anti-pattern: Steps in steps

Never write steps that call another steps. Instead, use plain old Ruby methods.

**Don't**

```ruby
When /^"(.?)" logs in do |username|
  steps %Q{
    Given I visit "/login"
    When I enter "Bob" in the "user name" field
      And I enter "tester" in the "password" field
      And I press the "login" button
    Then I should see the "welcome" page
  }
end
```

**Do**

```ruby
When /^"(.?)" logs in do |username|
  visit("/login")
  fill_in( "user name", :with => username )
  fill_in( "password", :with => "tester" )
  click_button( "login" )
  page.should have_content("welcome")
end
```

**Or even better**

Make it a method:

```ruby
def login_user(username)
  visit("/login")
  fill_in( "user name", :with => username )
  fill_in( "password", :with => "tester" )
  click_button( "login" )
  page.should have_content("welcome")
end

When /^"(.?)" logs in do |username|
  login_user(username)
end
```

If a support method such as `login_user` is called from multiple steps (which it definitely is), put it in a class and move it in `features/support` folder.

```ruby
# features/support/login_helpers.rb

class LoginHelpers

  def login_user(username)
    visit("/login")
    fill_in( "user name", :with => username )
    fill_in( "password", :with => "tester" )
    click_button( "login" )
    page.should have_content("welcome")
  end

  def another_logging_method . . .
end

World do
  LoginHelpers.new
end

# features/user/login.rb
When /^"(.?)" logs in do |username|
  login_user(username)
end
```

## Capybara methods over web_steps.rb

The web steps lead to imperative scenarios. Do not use them. Instead learn Capybara API and use Capybara methods.

Read more: [The training wheels came off](http://aslakhellesoy.com/post/11055981222/the-training-wheels-came-off)

**Don't**

Don't use web steps in scenarios, such as:

`When I click 'button'`

`And I follow "Information"`

**Do**

Use Capybara in step definitions:

`click_button 'button'`

`click_link 'Information'`

## Indent "And" steps with 2 spaces, "When" and "Then" with one space

**Do**

```gherkin
Given I want to have vertically aligned keywords
  And I use spaces for indentation
 When I indent When and Then keywords with 1 space
  And I indent And keywords with 2 spaces
 Then I see that all the keywords are nicely aligned
```

## Use step argument transforms

Use step argument transforms to DRY up step definitions.

Read more: https://blog.engineyard.com/2009/cucumber-step-argument-transforms/

Given the following scenario:

```gherkin
Given a listing "Piano" from user "bob"
When user "jane" sends message to user "bob" about listing "Piano"
Then user "bob" should have a new message about listing "Piano"
```

**Don't**

```ruby
Given /^a listing from user "(.*)" do |username|
  user = User.find_by_username(username)
  Listing.create(author: user)
end

When /^user "(.*)" sends message to user "(.*)" about listing "(.*)" do |sender_username, recipient_username, listing_title|
  sender = User.find_by_username(sender_username)
  recipient = User.find_by_username(recipient_username)
  listing = Listing.find_by_title(listing_title)
  Message.create(sender: user, recipient: recipient, listing: listing)
end

Then /^user "(.*)" should have a new message about listing "(.*)" do |recipient_username, listing_title|
  recipient = User.find_by_username(recipient_username)
  listing = Listing.find_by_title(listing_title)
  recipient.messages.find { |m| m.listing == listing }.should_not be_nil
end
```

**Do**

```ruby
# features/support/transforms.rb

Transform /^user "(.*)"$/ do |username|
  User.find_by_username(username)
end

Transform /^listing "(.*)"$/ do |listing_title|
  Listing.find_by_title(listing_title)
end

# features/messages/messabe_about_listing.rb

Given /^a listing from (user "(.*)") do |user|
  Listing.create(author: user)
end

When /^(user "(.*)") sends message to (user "(.*)") about (listing "(.*)") do |sender, recipient, listing|
  Message.create(sender: user, recipient: recipient, listing: listing)
end

Then /^(user "(.*)") should have a new message about (listing "(.*)") do |recipient, listing|
  recipient.messages.find { |m| m.listing == listing }.should_not be_nil
end
```

## After When comes Then

Do not group When steps and Then steps together. Instead, add a Then step preferably right after each When step.

**Don't**

```gherkin
When I do an action which may sent me an email or a private message
And I do another action which may sent me an email or a private message
And I do yet another action which may sent me an email or a private message
Then I should have 2 emails in my inbox
Then I should have 1 private message
```

Here's the thing: If you change the email/SMS sending logic so that the test fails (say, after the change you receive only 1 email and 2 private messages), can you tell which one of the When steps is the one that fails? No.

**Do**

```gherkin
When I do an action which may sent me an email or private message
Then I should have 1 emails in my inbox
When I do another action which may sent me an email or private message
Then I should have 1 private message
When I do yet another action which may sent me an email or private message
Then I should have 2 emails in my inbox
```

# Assume @current\_community and @current\_user

By default, assume that we are on current community

**Don't**

```gherkin
# scenario.rb
Given community "Food Market" has default browse view "map"
```

```ruby
# steps.rb
Given /^community "(.*)" has default browse view "(.*)"$/ do |community, view|
  Community.find(community).update_attribute(:default_view, view)
end
```

**Do**

```gherkin
# scenario
Given "map" is the default browse view
```

```ruby
# steps.rb
Given /^"(.*)" is the default browse view$/ do |view|
  @current_community.update_attribute(:default_view, view)
end
```

You can also assume instance value`@current_user` (and maybe even `@listing`, when referencing to recently created listing, but that's about it). **Avoid over-use.** Relying on using instance values makes it difficult to reuse your steps.

Of course if you need a reference to another community, then go ahead:

```gherkin
Given user "bob" is also member in community "Another community"
```

## Omit "there is" in Given steps


**Don't**

```gherkin
Given there is a user "bob" in the current community
```

**Do**

```gherkin
Given a user "bob"
```

...and assume current community.

## References:

1. https://github.com/cucumber/cucumber/wiki/Cucumber-Backgrounder
2. http://pivotallabs.com/cucumber-step-definitions-are-not-methods/
3. http://aslakhellesoy.com/post/11055981222/the-training-wheels-came-off
