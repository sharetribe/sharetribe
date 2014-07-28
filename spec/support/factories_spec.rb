# See https://github.com/thoughtbot/factory_girl/wiki/Testing-all-Factories-(with-RSpec)

describe "Factory Girl" do
  FactoryGirl.factories.map(&:name).each do |factory_name|
    describe "#{factory_name} factory" do

      # Test each factory
      it "is valid" do
        factory = FactoryGirl.build(factory_name)
        if factory.respond_to?(:valid?)
          # the lamba syntax only works with rspec 2.14 or newer;  for earlier versions, you have to call #valid? before calling the matcher, otherwise the errors will be empty
          expect(factory).to be_valid, factory.errors.full_messages.join("\n")
        end
      end
    end
  end
end