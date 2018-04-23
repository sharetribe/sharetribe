class Rack::Attack

  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blacklisting and
  # whitelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', :limit => 300, :period => 5.minutes) do |req|
    req.env['action_dispatch.remote_ip'].to_s # unless req.path.start_with?('/assets')
  end

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:session/ip:#{req.ip}"
  throttle('session/ip', :limit => 10, :period => 20.seconds) do |req|
    if req.path.end_with?('/sessions') && req.post?
      req.env['action_dispatch.remote_ip'].to_s
    end
  end


  # Throttle POST requests to /sessions by person[login] param
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:sessions/login:#{req.params['person']['login]']}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that's not very common and shouldn't happen to you. (Knock
  # on wood!)
  throttle("sessions/login", :limit => 10, :period => 20.seconds) do |req|
    if req.path.end_with?('/sessions') && req.post?
      # return the email if present, nil otherwise
      req.params['person']['login'].presence
    end
  end

  # Blocklist from Rails cache. See
  # https://github.com/kickstarter/rack-attack/wiki/Advanced-Configuration
  # Our implementation relies on redis cache for O(1) complexity in checking blocks
  if Rails.cache.class.to_s == "Readthis::Cache"
    Rack::Attack.blocklist('block') do |req|
      # if variable `block <ip>` exists in cache store, then we'll block the request
      Rails.cache.pool.with { |client| client.sismember('blocked', req.env['action_dispatch.remote_ip'].to_s) }
    end
  end

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they've successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  # self.throttled_response = lambda do |env|
  #  [ 503,  # status
  #    {},   # headers
  #    ['']] # body
  # end

  ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, req|
    data = {name: name,
            start: start,
            finish: finish,
            request_id: request_id,
            request_ip: req.env['action_dispatch.remote_ip'].to_s,
            matched: req.env['rack.attack.matched'],
            match_type: req.env['rack.attack.match_type'],
            match_data: req.env['rack.attack.match_data'],
            user_agent: req.env['HTTP_USER_AGENT'],
            referer: req.env['SERVER_NAME']
    }
    Rails.logger.info(data.to_json)
  end

end
