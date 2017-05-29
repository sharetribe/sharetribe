class SharetribeLogger
  def initialize(tag = nil, metadata_keys = [], log_target = Rails.logger)
    @tag = tag
    @log_target = log_target
    @metadata_keys = metadata_keys
    @metadata = {}
  end

  def debug(msg, type = nil, structured = nil)
    @log_target.debug(
      include_metadata(to_hash(msg, type, structured)).to_json)
  end

  def info(msg, type = nil, structured = nil)
    @log_target.info(
      include_metadata(to_hash(msg, type, structured)).to_json)
  end

  def warn(msg, type = nil, structured = nil)
    @log_target.warn(
      include_metadata(to_hash(msg, type, structured)).to_json)
  end

  def error(msg, type = nil, structured = nil)
    @log_target.error(
      include_metadata(to_hash(msg, type, structured)).to_json)
  end

  def add_metadata(new_data)
    unknown_keys = new_data.keys - @metadata_keys

    if unknown_keys.present?
      raise ArgumentError.new("Unknown metadata keys: #{unknown_keys}")
    end
    @metadata = @metadata.merge(new_data.slice(*@metadata_keys))
  end

  def info?
    true # FIXME-STR51
  end

  private

  def to_hash(msg, type, structured)
    HashUtils.compact({
                        tag: @tag,
                        free: msg,
                        type: type,
                        structured: structured,
                      })
  end

  def include_metadata(log_data)
    @metadata.merge(log_data)
  end
end
