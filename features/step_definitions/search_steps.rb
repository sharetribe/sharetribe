Given /^the (\w+) indexes are processed$/ do |model|
  ThinkingSphinx::Test.index "#{model.underscore}_core", "#{model.underscore}_delta"
  wait_until_index_finished()
end
