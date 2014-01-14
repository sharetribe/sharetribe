Given /^the (\w+) indexes are processed$/ do |model|
  model = model.titleize.gsub(/\s/, '').constantize
  ThinkingSphinx::Test.index *model.sphinx_index_names
  sleep(0.25) # Wait for Sphinx to catch up
end
