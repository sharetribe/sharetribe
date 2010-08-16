# These are now commented out because unstabilities with Rails 3, Thinking_sphinx2 and Cucumber
# See: http://freelancing-gods.com/posts/using_thinking_sphinx_with_cucumber
# http://freelancing-god.github.com/ts/en/testing.html
# http://github.com/freelancing-god/thinking-sphinx/issues/#issue/109
# Basically the problem is that the Listings are not found in search results even with these instructions
#   Failed to start searchd daemon. Check /Users/amvirola/kassi/log/searchd.log.


# require 'cucumber/thinking_sphinx/external_world'
# Cucumber::ThinkingSphinx::ExternalWorld.new
# 
# Before('@no-txn') do
#   DatabaseCleaner.start
# end
# 
# After('@no-txn') do
#   DatabaseCleaner.clean
# end
