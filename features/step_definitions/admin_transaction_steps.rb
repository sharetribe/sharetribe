module AdminTransactionSteps

  def build_transaction(transaction)
    transaction_opts = {
      title: transaction[:conversation_thread],
      created_at: eval(transaction[:started_at].gsub(' ', '.')),
      last_message_at: eval(transaction[:latest_activity].gsub(' ', '.')),
      community: Community.first
    }
    starter = Person.find_by_username(transaction[:starter])
    other_party = Person.find_by_username(transaction[:other_party])
    sum = transaction[:sum].to_i * 100 unless transaction[:sum].empty?

    conversation = FactoryGirl.build(
      :listing_conversation,
      transaction_opts.merge({
          transaction_transitions: [ FactoryGirl.build(:transaction_transition, { to_state: transaction[:status].to_sym }) ],
          listing: Maybe(transaction[:listing])
            .select { |title| title != "nil" }
            .map { |title| FactoryGirl.build(:listing, { title: title }) }
            .or_else(nil),
          payment: sum ? FactoryGirl.build(:braintree_payment, { sum_cents: sum, currency: transaction[:currency] }) : nil
        })
      )

    conversation.build_starter_participation(starter)
    conversation.build_participation(other_party)

    conversation
  end

  def to_title(name)
    name.gsub("_", " ").capitalize
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

World AdminTransactionSteps
Given(/^there are following transactions$/) do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |transaction|
    listing_conversation = build_transaction(transaction)
    listing_conversation.save!
  end
end

Then(/^I should see (\d+) transaction with status "(.*?)"$/) do |count, status_text|
  page.all("td", :text => status_text).length.should eq count.to_i
end

When(/^I sort by "(.*?)"$/) do |column|
  find_column(column).find("a").click
end

Then(/^I should see the transactions in ascending order by "(.*?)"$/) do |column|
  col_values = column_values(find_column_index(column))
  col_values.should eql col_values.sort
end

Then(/^I should see the transactions in descending order by "(.*?)"$/) do |column|
  col_values = column_values(find_column_index(column))
  col_values.should eql col_values.sort.reverse
end

Then(/^I should see the transactions in ascending time order by "(.*?)"$/) do |column|
  col_values = column_values(find_column_index(column))
    .map { |value| DateTime.parse(value) }
  col_values.should eql col_values.sort
end

Then(/^I should see the transactions in descending time order by "(.*?)"$/) do |column|
  col_values = column_values(find_column_index(column))
    .map { |value| DateTime.parse(value) }
  col_values.should eql col_values.sort.reverse
end
