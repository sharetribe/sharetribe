module BackgroundJobHelpers

  def process_jobs
    Delayed::Worker.new(:quiet => false).work_off
  end
end

World(BackgroundJobHelpers)