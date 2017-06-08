if defined? Kassi::Application
  Rails.application.configure do
    config.generators do |g|
      g.integration_tool :rspec
      g.test_framework   :rspec
    end
  end
end
