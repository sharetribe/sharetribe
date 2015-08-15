module EmailService::SES
  class Logger

    def log_request(method, params)
      request_id = SecureRandom.uuid
      Rails.logger.info(to_json_log_entry(:request,
                                          method,
                                          params,
                                          request_id))

      request_id
    end

    def log_result(result, method, request_id)
      if result.success
        Rails.logger.info(to_json_log_entry(:response,
                                            method,
                                            { successful: true },
                                            request_id)) unless result.nil?
      else
        Rails.logger.warn(to_json_log_entry(:response,
                                            method,
                                            { successful: false, error_msg: result.error_msg },
                                            request_id)) unless result.nil?
      end
    end

    def to_json_log_entry(type, method, params, request_id = nil)
      {
        tag: :aws_ses,
        type: type,
        method: method,
        params: params,
        request_id: request_id,
      }.to_json
    end
  end
end

