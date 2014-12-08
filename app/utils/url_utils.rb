module URLUtils
  module_function

  def append_query_param(url_str, param_key, param_val)
    uri = URI(url_str)
    args = URI.decode_www_form(uri.query || "") << [param_key, param_val]
    uri.query = URI.encode_www_form(args)
    uri.to_s
  end

  def remove_query_param(url_str, param_key)
    uri = URI(url_str)
    args = URI.decode_www_form(uri.query || "").reject { |(key, _)| param_key == key }
    uri.query = args.empty? ? nil : URI.encode_www_form(args)
    uri.to_s
  end

  # http://www.sharetribe.com/en/people -> en
  # http://www.sharetribe.com/en-US/people -> en-US
  #
  # Returns the first "folder" in path. Does not validate the locale
  def extract_locale_from_url(url)
    URI(url).path.split('/')[1]
  end
end
