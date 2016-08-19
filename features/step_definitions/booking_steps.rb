Then(/^(author ".*?") should be notified about the request from (starter ".*?")$/) do |author, starter|
  process_jobs
  user_should_have_email(author, "#{starter.name_or_username(@current_community)} has requested and authorized payment for Cool snowboard")
end
