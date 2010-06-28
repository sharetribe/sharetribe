require 'test_helper'

class CachedRessiEventTest < ActiveSupport::TestCase

  @@OPTIONS = { :return_value=>"nil",
    :parameters =>
    { :format => "json",
      :action => "show",
      :id => "c_hs6WxWOr3RofaaWPEYjL",
      :controller => "collections",
      :app_id => "cWslSQyIyr3yiraaWPEYjL" }.to_json,
    :application_id=>"cWslSQyIyr3yiraaWPEYjL",
    :action=>"CollectionsController#show",
    :session_id=>"63601",
    :user_id=>"biPssKjrCr3PQyaaWPEYjL",
    :ip_address=>"128.214.20.122",
    :semantic_event_id => "hololooo",
    :headers => {"foo" => "bar"}.to_json }


  test "create" do
    event = CachedRessiEvent.new(@@OPTIONS)
    assert event.save
  end
 
  if APP_CONFIG.log_to_ressi
    test "upload" do
      begin
        event = CachedRessiEvent.new(@@OPTIONS)
        assert event.save
        # the upload method itself doesn't destroy the uploaded from the database
        #assert_difference "CachedRessiEvent.count", -1 do
          event.upload
        #end
      rescue Errno::ECONNREFUSED => e
        puts "No connection to RESSI at #{APP_CONFIG.ressi_url}"
      rescue Exception => e
        assert false,  "Ressi timed out at #{APP_CONFIG.ressi_url}, #{e.message}"
      end
    end
  end

end
