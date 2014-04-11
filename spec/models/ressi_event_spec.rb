# encoding: UTF-8

require 'spec_helper'

describe RessiEvent do

  it "should get logged to Ressi when created" do
    # These tests require that the Ressi server is running at APP_CONFIG.ressi_url
    if APP_CONFIG.ressi_url && APP_CONFIG.log_to_ressi
      begin

        test_event = RessiEvent.new({
          :user_id => 'dMF4WsJ7Kr3BN6ab9B7ckF',
          :application_id => 'acm-TkziGr3z9Tab_ZvnhG',
          :session_id => 'BAh7BzoPc2Vzc2lvbl9pZGkCVREiCmZsYXNoSUM6J0FjdGlvbkNvbnRyb2xs ZXI6OkZsYXNoOjpGbGFzaEhhc2h7AAY6CkB1c2VkewA=--e3ae3baef1b6f0e680af4107e0f086b5f59f0da6',
          :ip_address => '130.233.194.26',
          :action => 'TestsController#testing_ressi_logging',
          :parameters => '{ "test": "ääkköset", "format": "json", "action": "pending_friend_requests", "controller": "people", "user_id": "bU8aHSBEKr3AhYaaWPEYjL"}', # JSON
          :return_value => '200',
          :headers => '{"SERVER_NAME": "ossi.alpha.sizl.org", "HTTP_MAX_FORWARDS": "10", "HTTP_X_PROTOTYPE_VERSION": "1.6.0.2", "PATH_INFO": "/people/bU8aHSBEKr3AhYaaWPEYjL/@pending_friend_requests", "HTTP_X_FORWARDED_HOST": "ossi.alpha.sizl.org", "HTTP_VIA": "1.1 ossi.alpha.sizl.org", "HTTP_ACCEPT_ENCODING": "gzip,deflate", "HTTP_USER_AGENT": "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.5) Gecko/2008120121 Firefox/3.0.5", "SCRIPT_NAME": "/", "SERVER_PROTOCOL": "HTTP/1.1", "HTTP_ACCEPT_LANGUAGE": "en-us,en;q=0.5", "HTTP_HOST": "ossi.alpha.sizl.org", "REMOTE_ADDR": "127.0.0.1", "SERVER_SOFTWARE": "Mongrel 1.1.5", "REQUEST_PATH": "/people/bU8aHSBEKr3AhYaaWPEYjL/@pending_friend_requests", "HTTP_REFERER": "http://ossi.alpha.sizl.org/jsclient/v1/", "HTTP_COOKIE": "_trunk_session=BAh7BzoPc2Vzc2lvbl9pZGkCVREiCmZsYXNoSUM6J0FjdGlvbkNvbnRyb2xs%0AZXI6OkZsYXNoOjpGbGFzaEhhc2h7AAY6CkB1c2VkewA%3D--e3ae3baef1b6f0e680af4107e0f086b5f59f0da6", "HTTP_ACCEPT_CHARSET": "ISO-8859-1,utf-8;q=0.7,*;q=0.7", "HTTP_VERSION": "HTTP/1.1", "HTTP_X_FORWARDED_SERVER": "ossi.alpha.sizl.org", "REQUEST_URI": "/people/bU8aHSBEKr3AhYaaWPEYjL/@pending_friend_requests", "SERVER_PORT": "80", "GATEWAY_INTERFACE": "CGI/1.2", "HTTP_X_FORWARDED_FOR": "130.233.194.26", "HTTP_ACCEPT": "text/javascript, text/html, application/xml, text/xml, */*", "HTTP_CONNECTION": "Keep-Alive", "HTTP_X_REQUESTED_WITH": "XMLHttpRequest", "REQUEST_METHOD": "GET"}',
          :semantic_event_id => 'running_ressi_event_spec'
          })
        test_event.should be_valid
        test_event.save.should be_true
        test_event.should_not be_nil
      rescue Errno::ECONNREFUSED => e
        # No need to output this
        # puts "No connection to RESSI (optional) at #{APP_CONFIG.ressi_url}"
      rescue NoMethodError => e
        puts "Ressi event error (#{e.class}) #{APP_CONFIG.ressi_url}, #{e.message}. This can happen if Ressi server is not available. You don't need to worry about this, unless specifically testing Ressi now."
      end

    end
  end
end
