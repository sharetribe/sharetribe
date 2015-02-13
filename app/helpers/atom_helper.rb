module AtomHelper

  # Paperclip might return full url or path depening on storage used (filesystem or S3)
  # This method will add the community domain in the beginning if it's just a path
  def ensure_full_image_url(initial_url)
    if initial_url =~ /^http/
      return initial_url
    else
      return "#{@url_root}#{initial_url}"
    end
  end
end
