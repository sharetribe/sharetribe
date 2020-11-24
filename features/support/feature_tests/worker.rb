module FeatureTests
  module Worker
    module_function

    def work_until(&block)
      worker = Delayed::Worker.new(quiet: true)

      default_max_wait_time = Capybara.default_max_wait_time
      Capybara.default_max_wait_time = 0.2

      begin
        Timeout.timeout(default_max_wait_time) do
          worker.work_off until block.call
        end
      ensure
        Capybara.default_max_wait_time = default_max_wait_time
      end
    end
  end
end
