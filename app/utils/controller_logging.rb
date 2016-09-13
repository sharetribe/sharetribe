module ControllerLogging

  module_function

  def append_request_info_to_payload!(request, payload)
    payload[:host] = request.host
    payload[:request_uuid] = request.uuid
    payload[:user_agent] = request.headers["User-Agent"] || ""
    payload[:referer] = request.headers["Referer"] || ""
    payload[:forwarded_for] = request.headers["X-Forwarded-For"] || ""
  end

end
