require 'spec_helper'

describe CachedRessiEvent do
  @OPTIONS = { :return_value=>"nil",
     :parameters =>
     { :format => "json",
       :action => "show",
       :id => "c_hs6WxWOr3RofaaWPEYjL",
       :controller => "collections",
       :app_id => "cWslSQyIyr3yiraaWPEYjL" }.to_json,
     :application_id=>"cWslSQyIyr3yiraaWPEYjL",
     :action=>"TestsController#testing_ressi_logging",
     :session_id=>"63601",
     :user_id=>"biPssKjrCr3PQyaaWPEYjL",
     :ip_address=>"128.214.20.122",
     :semantic_event_id => "running_cached_ressi_event_spec",
     :test_group_number => 2,
     :headers => {"foo" => "bar"}.to_json }

   it "should be created without errors" do
     event = CachedRessiEvent.new(@OPTIONS)
     event.save!
     CachedRessiEvent.count.should > 0
   end

   it "should be uploaded to ressi wtihout errors" do
     if APP_CONFIG.log_to_ressi
       begin
         event = CachedRessiEvent.new(@OPTIONS)
         event.save!
         event.upload
       rescue Errno::ECONNREFUSED => e
         # No need to output this
         # puts "No connection to RESSI (optional) at #{APP_CONFIG.ressi_url}"
       rescue NoMethodError => e
         puts "Ressi event error (#{e.class}) #{APP_CONFIG.ressi_url}, #{e.message}. This can happen if Ressi server is not available. You don't need to worry about this, unless specifically testing Ressi now."
       end
     end
   end
end
