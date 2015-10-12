class SharetribeLogger
  attr_writer(
    :community_id,
    :community_ident,
    :user_id,
    :username
  )

  def initialize(tag = nil, system_logger = Rails.logger)
    @tag = tag
    @system_logger = system_logger
  end

  def debug(msg, type = :other)
    @system_logger.debug(
      add_details(to_json(msg, type)))
  end

  def info(msg, type = :other)
    @system_logger.info(
      add_details(to_json(msg, type)))
  end

  def warn(msg, type = :other)
    @system_logger.warn(
      add_details(to_json(msg, type)))
  end

  def error(msg, type = :other)
    @system_logger.error(
      add_details(to_json(msg, type)))
  end

  private

  def to_json(msg, type)
    {
      tag: @tag,
      free: msg,
      type: type
    }
  end

  def add_details(log_data)
    {
      user_id: @user_id,
      username: @username,
      community_id: @community_id,
      community_ident: @community_ident
    }.merge(log_data)
  end
end
