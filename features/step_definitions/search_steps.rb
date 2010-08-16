# Given /^the (\w+) indexes are processed$/ do |model|
#   model = model.titleize.gsub(/\s/, '').constantize
#   ThinkingSphinx::Test.index *model.sphinx_index_names
# end