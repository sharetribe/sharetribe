# Given /^the (\w+) indexes are processed$/ do |model|
#   model = model.titleize.gsub(/\s/, '').constantize
#   ThinkingSphinx::Test.index *model.sphinx_index_names
#   # ThinkingSphinx::Test.index
#   # sleep(0.25) # Wait for Sphinx to catch up
# end