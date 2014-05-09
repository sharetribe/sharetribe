# credits to: http://cookieshq.co.uk/posts/how-to-create-multiple-facebook-omniauth-strategies-for-the-same-application/

module OmniAuth::Strategies

  # Make a subclass for each community which has custom FB login
  begin
    Community.all_with_custom_fb_login.each do |community|
      c = Class.new(Facebook) do
        define_method :name do
          "facebook_app_#{community.facebook_connect_id}".to_sym
        end

      end
      Kernel.const_set "FacebookApp#{community.facebook_connect_id}", c
    end
  rescue ActiveRecord::StatementInvalid => e
    # in some environments (e.g. Travis CI) database might not be fully set up when this is run and in that case just skip additional methods.
  end

end
