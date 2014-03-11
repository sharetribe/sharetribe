class BraintreeService
  include Braintree::Transaction::EscrowStatus

  class << self
    def hide_account_number(account_number, nums_visible=2)
      stripped_account_number = (account_number || "").strip
      asterisks = (stripped_account_number.length - 1) - nums_visible
      (0..asterisks).inject("") { |a, _| a + "*" } + stripped_account_number.last(nums_visible)
    end
  end
end