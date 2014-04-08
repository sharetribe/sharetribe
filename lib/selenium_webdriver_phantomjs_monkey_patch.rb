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
class Selenium::WebDriver::PortProber
  def self.free?(port)
    true
  end
end

class Selenium::WebDriver::PhantomJS::Service
  def create_process(args)
    puts "Starting monkey-patched PhantomJS Selenium Webdriver"

    Struct.new("ChildProcessFake") do
      def start() end
      def exited?() true end
    end.new
  end
end