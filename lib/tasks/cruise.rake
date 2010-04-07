desc 'Used for Cruise Control Continuous Integration.'
task :cruise => ['db:migrate', :test] do
  # Tähän kohtaan voi lisätä komennon joka esim. positaa ferretin indexina
  #system("rm jotain")
  Rake::Task["test"].invoke rescue got_error = true
end