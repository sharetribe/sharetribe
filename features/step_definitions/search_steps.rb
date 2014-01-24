Given /^the (\w+) indexes are processed$/ do |model|
  ThinkingSphinx::Test.index "#{model.downcase}_core", "#{model.downcase}_delta"
  sleep(0.25) # Wait for Sphinx to catch up
end
