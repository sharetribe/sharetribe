# Credits to Avand: http://avandamiri.com/2011/10/11/serving-different-robots-using-rack.html

class RobotsGenerator

  def self.call(env)
    return [404, {}, []] if env[:current_marketplace].nil?

    begin

      # Disallow indexing from other than production environments
      body =
        if Rails.env.production?
          index_content(env)
        else
          no_index_content()
        end

      # Adding cache control here seemed to cause strange errors in production env
      headers = {"Content-Type" => "text/plain" }

      return [200, headers, [body]]
    rescue Errno::ENOENT
      return [404, {}, ['# A robots.txt is not configured']]
    end
  end

  def self.index_content(env)
    req = Rack::Request.new(env)

    [
      "User-agent: *",
      "Allow: /",
      "Sitemap: #{req.scheme}://#{req.host_with_port}/sitemap.xml.gz"
    ].join("\n")
  end

  def self.no_index_content
    [
      "User-agent: *",
      "Disallow: /"
    ].join("\n")
  end
end
