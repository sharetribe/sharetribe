# With this shell script you can do refund
# Change settings and the transaction id before running

require "rubygems"
require "braintree"

Braintree::Configuration.environment = :production
Braintree::Configuration.merchant_id = "xxxxxxx"
Braintree::Configuration.public_key = "yyyyyyyy"
Braintree::Configuration.private_key = "zzzzzzzzzz"


def cancel_escrow(transaction_id)
  result = Braintree::Transaction.refund(transaction_id)
 
  if result.success?
    puts "Successfully refunded from escrow"
  else
    puts "Failed to cancel escrow release"
    result.errors.each { |e| puts e.inspect }
  end
end

def transaction_status(transaction_id)
  txn = Braintree::Transaction.find(transaction_id)

  puts "Found transaction #{transaction_id}"
  puts "  amount:        #{txn.amount}"
  puts "  status:        #{txn.status}"
  puts "  escrow_status: #{txn.escrow_status}"
end

# transaction_status("1234abcd")
# cancel_escrow("1234abcd")
