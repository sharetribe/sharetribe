When 'the system processes jobs' do
  Delayed::Worker.new(:quiet => true).work_off
end