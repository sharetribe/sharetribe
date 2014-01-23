Given /^the (\w+) indexes are processed$/ do |model|
  ThinkingSphinx::Test.index model.downcase
  sleep(0.25) # Wait for Sphinx to catch up
end
