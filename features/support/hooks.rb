Before do
  Capybara.default_host = 'http://test.lvh.me:9887'
  Capybara.server_port = 9887
  Capybara.app_host = "http://test.lvh.me:9887"
  @current_community = Community.where(ident: "test").first
end

Before('@javascript') do
  if Capybara.current_driver == :poltergeist
    # Store the reference to original confirm() function
    # (this might be mocked later)
    page.execute_script("window.__original_confirm = window.confirm")
  end
end

After('@javascript') do
  if Capybara.current_driver == :poltergeist
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
    save_screenshot("#{scenario.name}.png")

    if page.driver.browser.respond_to?(:manage)
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

    # Enable this for CircleCI debuging
    if ENV['CIRCLE_TEST_REPORTS'].present?
      puts ""
      puts "*** Rails logs at (#{I18n.l(Time.current, format: '%Y-%m-%d %H:%M:%S %z')}):"
      puts ""
      file = File.join(Rails.root, 'log', 'test.log')
      IO.readlines(file).last(500).each do |line|
        puts line
      end
    end
  end
end

After do
  Timecop.return
end
