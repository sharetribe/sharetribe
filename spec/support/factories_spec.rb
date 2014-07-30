# See https://github.com/thoughtbot/factory_girl/wiki/Testing-all-Factories-(with-RSpec)

describe "Factory Girl" do

  # List here factories that should be ignored.
  # E.g. :payment is ignored, since it's a super class and shouldn't be instantiated
  ignored_factories = [
    :payment
  ]

  (FactoryGirl.factories.map(&:name) - ignored_factories).each do |factory_name|
    describe "#{factory_name} factory" do


      it "is valid" do
        factory = FactoryGirl.build(factory_name)
        if factory.respond_to?(:valid?)
          factory.valid?

          expect(factory).to be_valid, error_message(factory)
        end
      end
    end
  end

  def error_message(factory)
    factory.errors.messages.map do |(field_name, errors)|
      ":#{field_name} => #{errors.join(', ')}"
    end.join("\n")
  end
end