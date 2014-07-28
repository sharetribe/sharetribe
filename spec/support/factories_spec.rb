# See https://github.com/thoughtbot/factory_girl/wiki/Testing-all-Factories-(with-RSpec)

describe "Factory Girl" do

  ignored_factories = [
    :payment
  ]

  (FactoryGirl.factories.map(&:name) - ignored_factories).each do |factory_name|
    describe "#{factory_name} factory" do

      # Test each factory
      it "is valid" do
        factory = FactoryGirl.build(factory_name)
        if factory.respond_to?(:valid?)
          # the lamba syntax only works with rspec 2.14 or newer;  for earlier versions, you have to call #valid? before calling the matcher, otherwise the errors will be empty
          factory.valid?
          error_msg = factory.errors.messages.map { |(field_name, errors)| ":#{field_name} => #{errors.join(', ')}" }.join("\n")
          expect(factory).to be_valid, error_msg
        end
      end
    end
  end
end