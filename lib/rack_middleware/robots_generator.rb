# Credits to Avand: http://avandamiri.com/2011/10/11/serving-different-robots-using-rack.html

class RobotsGenerator

  # Use the config/robots.txt in production.
  # Disallow everything for all other environments.
  def self.call(env)
    begin

      if Rails.env.production?
        body = File.read Rails.root.join('config', 'robots.txt')
      else
        body = "User-agent: *\nDisallow: /"
      end

      # Adding cache control here seemed to cause strange errors in production env
      headers = {"Content-Type" => "text/plain" }
      
      return [200, headers, [body]]
    rescue Errno::ENOENT
      return [404, {}, ['# A robots.txt is not configured']]
    end
  end
end
