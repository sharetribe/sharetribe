When 'the system processes jobs' do
  Delayed::Worker.new.work_off
end