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

def find_merchant(merchant_id)
  merchant = Braintree::MerchantAccount.find(merchant_id)

  puts "Found merchant #{merchant_id}"
  puts "Info: #{merchant.inspect}"
  puts "Individual details:"
  print_attrs(merchant.individual_details, %w(first_name last_name date_of_birth email phone ssn_last_4))
end

#
# Example: update_individual_details("1234abcd", {last_name: "Last name", date_of_birth: "1990-01-01"})
#
def update_individual_details(merchant_id, details)
  result = Braintree::MerchantAccount.update(merchant_id, individual: details)

  if result.success?
    puts "Successfully updated merchant account individual details"
  else
    puts "Failed to update merchant account individual details"
    result.errors.each { |e| puts e.inspect }
  end
end

def print_attrs(obj, attrs)
  attrs.each do |attr|
    puts "  #{attr}: #{obj.send(attr.to_sym)}"
  end
end

# transaction_status("1234abcd")
# cancel_escrow("1234abcd")
# find_merchant("1234abcd")

update_individual_details("1234abcd", {last_name: "Last name", date_of_birth: "1990-01-01"})