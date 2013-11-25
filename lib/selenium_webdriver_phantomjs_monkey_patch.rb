##
# Use PhantomJS and Selenium WebDriver without opening/closing Phantom between sessions
#
# Monkey-patch two Selenium WebDriver classes
# - PortProber
# - PhantomJS::Service

##
# Disable port prober
#
# - The default port for PhantoJS WebDriver is 8910
# - PortProber uses 8910, but if it's not free, it tries 8911 etc.
# - Disable port prober
#
Selenium::WebDriver::PortProber.class_eval do
  def self.free?(port)
    true
  end
end

##
# Don't start new PhantomJS process
#
Selenium::WebDriver::PhantomJS::Service.class_eval do
  def start(args = [])
    require 'selenium/webdriver/common'

    if @process && @process.alive?
      raise "already started: #{@uri.inspect} #{@executable.inspect}"
    end

    puts "Starting monkey-patched PhantomJS Selenium Webdriver"

    # @process = create_process(args)
    # @process.start

    socket_poller = Selenium::WebDriver::SocketPoller.new Selenium::WebDriver::Platform.localhost, @uri.port, Selenium::WebDriver::PhantomJS::Service::START_TIMEOUT

    unless socket_poller.connected?
      raise Selenium::WebDriver::Error::WebDriverError, "unable to connect to phantomjs @ #{@uri} after #{Selenium::WebDriver::PhantomJS::Service::START_TIMEOUT} seconds"
    end

    Selenium::WebDriver::Platform.exit_hook { stop } # make sure we don't leave the server running
  end
end