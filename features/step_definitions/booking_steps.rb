Then(/^(author ".*?") should be notified about the request from (starter ".*?")$/) do |author, starter|
  process_jobs
  user_should_have_email(author, "#{starter.name_or_username(@current_community)} has requested and authorized payment for Cool snowboard")
end

Then(/^(author ".*?") and (starter ".*?") should receive receipts for payment$/) do |author, starter|
  process_jobs

  user_should_have_email(author, "You have received a new payment")
  user_should_have_email(starter, "Receipt of payment")
end

When(/^(author ".*?") and (starter ".*?") should be notified about automatic confirmation$/) do |author, starter|
  process_jobs
  user_should_have_email(author, "Order completed - remember to give feedback")
  user_should_have_email(starter, "Order automatically completed - remember to give feedback")
end
