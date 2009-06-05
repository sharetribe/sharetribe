desc 'Used for Cruise Control Continuous Integration.'
task :cruise => ['db:migrate', :test] do
  Rake::Task["test"].invoke rescue got_error = true
end