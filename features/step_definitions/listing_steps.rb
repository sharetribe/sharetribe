When /^I attach "([^\"]*)" image to the "([^\"]*)" file field$/ do |filename, field|
  type = filename.split(".")[1]

  if type == "jpg"
    type = "image/jpeg"
  end

  attach_file field, File.join(Rails.root, "/spec/fixtures", filename), type
end

Then /^I should see tag "(.+)"$/ do |selector|
  (Hpricot(response.body)/selector).should_not be_empty
end