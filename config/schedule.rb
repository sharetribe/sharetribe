# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"

set :output,  {:standard => "log/cron.log"} 
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 1.hours do
  rake "thinking_sphinx:index" 
end

every 1.day, :at => '11:57pm' do
  rake "kassi:calculate_statistics"
end

# Upload cached Ressi events.
# If Ressi (Research data collection) is not in use, this doesn't do anything.
every 1.day, :at => '1am' do
  rake "ressi:upload"
end

every :tuesday, :at => "2pm" do
  runner "PersonMailer.deliver_community_updates"
end