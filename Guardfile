# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|js|html))).*}) { |m| "/assets/#{m[3]}" }
end

guard 'spork', :wait => 60, test_unit: false, :cucumber_env => { 'RAILS_ENV' => 'test' }, :rspec_env => { 'RAILS_ENV' => 'test' } do
  
  # Load for all envs (rspec and cucumber)
  watch('config/application.rb')
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile.lock')
  watch('Guardfile')
  watch('spec/factories.rb')
  watch('app/helpers/application_helper.rb')
  watch('app/helpers/email_helper.rb')
  watch('app/helpers/errors_helper.rb')
  watch('app/models/community.rb')
  watch('app/models/email.rb')
  watch('app/models/person.rb')
  watch('config/boot.rb')
  watch('config/config_loader.rb')
  watch('config/environment.rb')
  watch('config/environments/test.rb')
  watch('config/routes.rb')
  watch('lib/devise/encryptors/asi.rb')
  watch('lib/i18n_action_mailer/i18n_action_mailer.rb')
  watch('lib/mercury/authentication.rb')
  watch('lib/np_guid/usesnpguid.rb')
  watch('lib/np_guid/uuid22.rb')
  watch('lib/np_guid/uuidtools.rb')
  watch('lib/rack_middleware/custom_domain_cookie.rb')
  watch('lib/rack_middleware/robots_generator.rb')
  watch('lib/routes/api_request.rb')
  watch('lib/routes/community_domain.rb')
  watch('test/helper_modules.rb')

  # Load for RSpec only
  watch('spec/spec_helper.rb') { :rspec }

  # Load for Cucumber only
  watch('app/helpers/categories_helper.rb') { :cucumber }
  watch('app/models/category.rb') { :cucumber }
  watch('app/models/category_translation.rb') { :cucumber }
  watch('app/models/classification.rb') { :cucumber }
  watch('app/models/community_category.rb') { :cucumber }
  watch('app/models/payment_gateway.rb') { :cucumber }
  watch('app/models/payment_gateways/checkout.rb') { :cucumber }
  watch('app/models/payment_gateways/mangopay.rb') { :cucumber }
  watch('app/models/share_type.rb') { :cucumber }
  watch('app/models/share_type_translation.rb') { :cucumber }
  watch('db/seeds.rb') { :cucumber }
  watch(%r{features/support/}) { :cucumber }
end

guard 'rspec', :all_on_start => false, :all_after_pass => false do
  watch('Guardfile')
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  # Rails example
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }

  # Capybara features specs
  watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/features/#{m[1]}_spec.rb" }

  # Turnip features and steps
  watch(%r{^spec/acceptance/(.+)\.feature$})
  watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$})   { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'spec/acceptance' }
end