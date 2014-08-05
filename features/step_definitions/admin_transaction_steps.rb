Given(/^there are following transactions$/) do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |transaction|
    transaction_opts = {
                         title: transaction[:conversation_thread],
                         created_at: eval(transaction[:started_at].gsub(' ', '.')),
                         last_message_at: eval(transaction[:latest_activity].gsub(' ', '.')),
                         community: Community.first,
                         participants: [ Person.find_by_username(transaction[:starter]),
                                         Person.find_by_username(transaction[:other_party]) ]
                       }

    if(transaction[:listing].empty?)
      FactoryGirl.create(:conversation, transaction_opts)
    else
      FactoryGirl.create(:listing_conversation,
                         transaction_opts.merge({
                                                  listing: FactoryGirl.create(:listing, { title: transaction[:listing] })
                                                }))
    end
  end
  binding.pry
end

Then(/^I should see (\d+) transaction with status "(.*?)"$/) do |arg1, arg2|
  pending
end