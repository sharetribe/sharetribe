module ApiHelper

  # Paperclip might return full url or path depening on storage used (filesystem or S3)
  # This method will add the community domain in the beginning if it's just a path
  def ensure_full_image_url(initial_url)
    if initial_url =~ /^http/
      return initial_url
    else
      return "#{@url_root}#{initial_url}"
    end
  end

  def api_version
    default_version = '2'
    pattern = /application\/vnd\.sharetribe.*version=([\w]+)/
    if request.env['HTTP_ACCEPT']
      return request.env['HTTP_ACCEPT'][pattern, 1] || default_version
    else
      return default_version
    end
  end

  # just a small helper to check if the version "alpha" or "1" is in use
  def api_version_alpha?
    api_version == "1" || api_version == "alpha"
  end
end
