module BackgroundJobHelpers

  def process_jobs
    success, failure = Delayed::Worker.new(:quiet => false).work_off

    if failure > 0
      raise "Delayed job failed"
    end
  end
end

World(BackgroundJobHelpers)
