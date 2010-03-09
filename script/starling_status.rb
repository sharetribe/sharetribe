require 'pp'

puts '=> Loading Rails...'

require File.dirname(__FILE__) + '/../config/environment'
require File.dirname(__FILE__) + '/../vendor/plugins/workling/lib/workling/remote/invokers/basic_poller'
require File.dirname(__FILE__) + '/../vendor/plugins/workling/lib/workling/routing/class_and_method_routing'

puts '** Rails loaded.'

trap(:INT) { exit }

client = Workling::Clients::MemcacheQueueClient.new
  
begin
  client.connect
  client.reset
  
  client.stats # do this so that connection is shown as established below. 
  
  puts "Queue state:"
  pp client.inspect
  pp "Active?: #{client.active?}"
  pp "Read Only?: #{client.readonly?}"
  puts ""
  puts "Servers:"
  pp client.servers
  puts ""
  puts "Queue stats:"
  pp client.stats

  puts "\nThread Stats:"
  pp Thread.list
ensure
  puts '** Exiting'
  client.close
end