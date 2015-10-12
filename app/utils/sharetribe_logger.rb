class SharetribeLogger
  attr_writer(
    :community_id,
    :community_ident,
    :user_id,
    :username,
    :request_uuid
  )

  def initialize(tag = nil, log_target = Rails.logger)
    @tag = tag
    @log_target = log_target
  end

  def debug(msg, type = :other, structured = nil)
    @log_target.debug(
      add_details(to_hash(msg, type, structured)).to_json)
  end

  def info(msg, type = :other, structured = nil)
    @log_target.info(
      add_details(to_hash(msg, type, structured)).to_json)
  end

  def warn(msg, type = :other, structured = nil)
    @log_target.warn(
      add_details(to_hash(msg, type, structured)).to_json)
  end

  def error(msg, type = :other, structured = nil)
    @log_target.error(
      add_details(to_hash(msg, type, structured)).to_json)
  end

  private

  def to_hash(msg, type, structured)
    {
      tag: @tag,
      free: msg,
      type: type,
      structured: structured,
    }
  end

  def add_details(log_data)
    {
      user_id: @user_id,
      username: @username,
      community_id: @community_id,
      community_ident: @community_ident,
      request_uuid: @request_uuid
    }.merge(log_data)
  end
end
