Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  [
    "--headless",
    "--window-size=1280x1280",
    "--disable-gpu" # https://developers.google.com/web/updates/2017/04/headless-chrome
  ].each { |arg| options.add_argument(arg) }

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

if false # rubocop:disable Lint/LiteralAsCondition
  require 'capybara/poltergeist'

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, js_errors: false)
  end
  Capybara.javascript_driver = :poltergeist
else
  # It does not work proper. It cannot fill in fields.
  # https://github.com/teamcapybara/capybara/issues/1890
  # Google Chrome 71.0.3578.80
  require 'webdrivers'
  # Webdrivers::Chromedriver.version = '2.46'

  # :selenium_chrome_headless
  Capybara.javascript_driver = :selenium_chrome_headless
end


Capybara.default_max_wait_time = 20
Capybara.ignore_hidden_elements = true
Capybara.default_selector = :css
