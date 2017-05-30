Before do
  Capybara.default_host = 'http://test.lvh.me:9887'
  Capybara.server_port = 9887
  Capybara.app_host = "http://test.lvh.me:9887"
  @current_community = Community.where(ident: "test").first
end

Before('@javascript') do
  if ENV['PHANTOMJS']
    Capybara.current_driver = :webdriver_phantomjs
    page.driver.browser.manage.window.resize_to(1024, 768)

    # Store the reference to original confirm() function
    # (this might be mocked later)
    page.execute_script("window.__original_confirm = window.confirm")
  end
end

After('@javascript') do
  if ENV['PHANTOMJS']
    # Restore maybe mocked confirm()
    page.execute_script("window.confirm = window.__original_confirm")
  end
end

Before ('@subdomain2') do
  Capybara.default_host = 'http://test2.lvh.me:9887'
  Capybara.app_host = "http://test2.lvh.me:9887"
  @current_community = Community.where(ident: "test2").first
end

Before ('@no_subdomain') do
  Capybara.default_host = 'http://lvh.me:9887'
  Capybara.app_host = "http://lvh.me:9887"
end

After('@no_subdomain') do
  Capybara.default_host = 'http://test.lvh.me:9887'
  Capybara.app_host = "http://test.lvh.me:9887"
end

Before ('@www_subdomain') do
  Capybara.default_host = 'http://www.lvh.me:9887'
  Capybara.app_host = "http://www.lvh.me:9887"
end

After('@www_subdomain') do
  Capybara.default_host = 'http://test.lvh.me:9887'
  Capybara.app_host = "http://test.lvh.me:9887"
end

After do |scenario|
  if(scenario.failed?)
    FileUtils.mkdir_p 'tmp/screenshots'
    save_screenshot("tmp/screenshots/#{scenario.name}.png")

    # Print browser logs after failing test
    #
    # Please note that Cabybara hijacks the `puts` method. That's why it's not sure
    # how and when the logs are printed. Depending on the formatter the logs may
    # be printed immediately (the defaul formatter) or not at all (pretty formatter)
    # The "sharetribe" formatter prints these normally after a failing test, as expected.
    puts ""
    puts "*** Browser logs:"
    puts ""
    puts page.driver.browser.manage.logs.get("browser").map { |log_entry|
      "[#{Time.at(log_entry.timestamp.to_i)}] [#{log_entry.level}] #{log_entry.message}"
    }.join("\n")
  end
end

After do
  Timecop.return
end
