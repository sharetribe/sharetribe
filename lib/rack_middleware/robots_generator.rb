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

      # Heroku can cache content for free using Varnish
      headers = { 'Cache-Control' => "public, max-age=#{1.year.seconds.to_i}", "Content-Type" => "text/plain" }

      [200, headers, [body]]
    rescue Errno::ENOENT
      [404, {}, ['# A robots.txt is not configured']]
    end
  end
end
