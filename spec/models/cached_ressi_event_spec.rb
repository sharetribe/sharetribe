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
end
