Given(/^there are following transactions$/) do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |transaction|
    transaction_opts = {
      title: transaction[:conversation_thread],
      created_at: eval(transaction[:started_at].gsub(' ', '.')),
      last_message_at: eval(transaction[:latest_activity].gsub(' ', '.')),
      community: Community.first
    }
    starter = Person.find_by_username(transaction[:starter])
    other_party = Person.find_by_username(transaction[:other_party])
    sum = transaction[:sum].to_i * 100 unless transaction[:sum].empty?

    conversation =
      if(transaction[:listing].empty?)
        FactoryGirl.build(:conversation, transaction_opts)
      else
        FactoryGirl.build(
        :listing_conversation,
        transaction_opts.merge({
            transaction_transitions: [ FactoryGirl.build(:transaction_transition, { to_state: transaction[:status].to_sym }) ],
            listing: FactoryGirl.build(:listing, { title: transaction[:listing] }),
            payment: sum ? FactoryGirl.build(:braintree_payment, { sum_cents: sum, currency: transaction[:currency] }) : nil
          })
        )
      end
    conversation.build_starter_participation(starter)
    conversation.build_participation(other_party)
    conversation.save!
  end
end

Then(/^I should see (\d+) transaction with status "(.*?)"$/) do |count, status_text|
  page.all("td", :text => status_text).length.should eq count.to_i
end
