module AdminConversationSteps

  def to_title(name)
    name.tr("_", " ").capitalize
  end

  def find_column(column)
    page.all("thead > tr > th").find { |elem| elem.text.starts_with?(to_title(column)) }
  end

  def find_column_index(column)
    page.all("thead > tr > th").find_index { |elem| elem.text.starts_with?(to_title(column)) }
  end

  def column_values(column_index)
    page.all("tbody > tr").map { |row| row.all("td")[column_index].text }
  end

end

World AdminConversationSteps
Given(/^there are following transactions$/) do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |transaction|
    listing_conversation = build_transaction(transaction)
    listing_conversation.save!
  end
end

Then(/^I should see a conversation started from "(.*?)" with status "(.*?)"$/) do |starting_page, status_text|
  expect(page.all("td", :text => status_text).length).to eq 1
  expect(page.all("td", :text => starting_page).length).to eq 1
end
