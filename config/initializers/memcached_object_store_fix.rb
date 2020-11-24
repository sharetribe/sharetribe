#code credits to Chris Lowder at: http://stackoverflow.com/questions/3531588/memcached-as-an-object-store-in-rails

Rails.cache.instance_eval do
  def fetch(key, options = {}, rescue_and_require=true)
    super(key, options)

  rescue ArgumentError => ex
    if rescue_and_require && /^undefined class\/module (.+?)$/ =~ ex.message
      self.class.const_missing($1)
      fetch(key, options, false)
    else
      raise ex
    end
  end
end
