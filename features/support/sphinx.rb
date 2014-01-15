require 'cucumber/thinking_sphinx/external_world'
Cucumber::ThinkingSphinx::ExternalWorld.new
Cucumber::Rails::World.use_transactional_fixtures = false
