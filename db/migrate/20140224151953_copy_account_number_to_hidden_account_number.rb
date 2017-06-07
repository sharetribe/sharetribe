class CopyAccountNumberToHiddenAccountNumber < ActiveRecord::Migration

  class BraintreeAccount < ApplicationRecord
  end

  # Copied from BraintreeApi
  def hide_account_number(account_number, nums_visible=2)
    stripped_account_number = account_number.strip
    asterisks = (stripped_account_number.length - 1) - nums_visible
    (0..asterisks).inject("") { |a, _| a + "*" } + stripped_account_number.last(nums_visible)
  end

  def up
    BraintreeAccount.reset_column_information

    BraintreeAccount.find_each do |account|
      account.hidden_account_number = hide_account_number(account.account_number)
      account.save!
    end
  end

  def down
    BraintreeAccount.reset_column_information
    BraintreeAccount.update_all(:hidden_account_number => nil)
  end
end
