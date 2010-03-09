puts '=> Loading Rails...'

require File.dirname(__FILE__) + '/../../../../config/environment'
require File.dirname(__FILE__) + '/../lib/workling/remote'
require File.dirname(__FILE__) + '/../lib/workling/remote/invokers/basic_poller'
require File.dirname(__FILE__) + '/../lib/workling/remote/invokers/threaded_poller'
require File.dirname(__FILE__) + '/../lib/workling/remote/invokers/eventmachine_subscriber'
require File.dirname(__FILE__) + '/../lib/workling/routing/class_and_method_routing'

client = Workling::Remote.dispatcher.client
invoker = Workling::Remote.invoker
poller = invoker.new(Workling::Routing::ClassAndMethodRouting.new, client.class)

puts '** Rails loaded.'
puts "** Starting #{ invoker }..."
puts '** Use CTRL-C to stop.'

ActiveRecord::Base.logger = Workling::Base.logger
ActionController::Base.logger = Workling::Base.logger

trap(:INT) { poller.stop; exit }

begin
  poller.listen
ensure
  puts '** No Worklings found.' if Workling::Discovery.discovered.blank?
  puts '** Exiting'
end

def tail(log_file)
  cursor = File.size(log_file)
  last_checked = Time.now
  tail_thread = Thread.new do
    File.open(log_file, 'r') do |f|
      loop do
        f.seek cursor
        if f.mtime > last_checked
          last_checked = f.mtime
          contents = f.read
          cursor += contents.length
          print contents
        end
        sleep 1
      end
    end
  end
  tail_thread
end