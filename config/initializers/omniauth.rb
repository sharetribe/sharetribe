# credits to: http://cookieshq.co.uk/posts/how-to-create-multiple-facebook-omniauth-strategies-for-the-same-application/
 
module OmniAuth::Strategies
  
  # Make a sbuclass for each community which has custom FB login  
  Community.with_custom_fb_login.each do |community|
    c = Class.new(Facebook) do
      define_method :name do
        "facebook_app_#{community.facebook_connect_id}".to_sym
      end
      
    end
    Kernel.const_set "FacebookApp#{community.facebook_connect_id}", c
  end
 
 
end