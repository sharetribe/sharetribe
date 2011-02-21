# Commented away for now, as not working completely yet

# When /^I send sms "([^"]*)"$/ do |message|
#   message = SmsHelper.parse({"message" => message, "msisdn" => @test_person.phone_number, "@id" => "example_test_id"})
#   SmsHelper.should_receive(:get_messages).and_return([message])
#   SmsHelper.should_receive(:delete_messages).and_return(true)
#   get "/en/sms"
# end

