module PaypalService::API::RequestWrapper

  # Depends on including class to define logger getter
  # Depends on including class to define paypal_merchant getter


  def with_success(cid, txid, request, opts = { error_policy: {} }, &block)
    retry_codes, try_max, finally = parse_policy(opts[:error_policy])
    response = try_operation(retry_codes, try_max) { paypal_merchant.do_request(request) }

    if (response[:success])
      block.call(response)
    else
      finally.call(cid, txid, request, response)
    end
  end

  def parse_policy(policy)
    [ Maybe(policy[:codes_to_retry]).or_else([]),
      Maybe(policy[:try_max]).or_else(1),
      Maybe(policy[:finally]).or_else(method(:log_and_return)) ]
  end

  def try_operation(retry_codes, try_max, &op)
    result = op.call()
    attempts = 1

    while (!result[:success] && attempts < try_max && retry_codes.include?(result[:error_code]))
      result = op.call()
      attempts = attempts + 1
    end

    result
  end

  def log_and_return(cid, txid, request, err_response, data = {})
    @logger.warn("PayPal operation #{request[:method]} failed. Community: #{cid}, transaction: #{txid}, error code: #{err_response[:error_code]}, msg: #{err_response[:error_msg]}")
    Result::Error.new(
      "Failed response from Paypal. Error code: #{err_response[:error_code]}, msg: #{err_response[:error_msg]}",
      {
        community_id: cid,
        transaction_id: txid,
        paypal_error_code: err_response[:error_code]
      }.merge(data)
    )
  end
end
