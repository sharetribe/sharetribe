# Modules in this file are included in both specs and cucumber steps.

module TestHelpers
  
  def create_listing(listing_type, category, share_type)
    listing_params = {:category => category}
    if category
      case category
      when "favor"
        listing_params.merge!({ :share_type => nil, :listing_type => listing_type})
      when "rideshare"
        listing_params.merge!({:share_type => nil, :origin => "test", :destination => "test2", :listing_type => listing_type})
      else
        if share_type.nil? && ["item", "housing"].include?(category)
          share_type = listing_type.eql?("request") ? "buy" : "sell"
        end
        listing_params.merge!({ :share_type => share_type, :listing_type => listing_type})
      end
    else
      listing_params[:category] = "item"
    end
    
    # set author manually as factory doesn't default to kassi_testperson1
    test_person, session = get_test_person_and_session
    listing_params.merge!({:author => test_person})
    
    
    listing = FactoryGirl.create(:listing, listing_params)
  end
  
  def get_test_person_and_session(username="kassi_testperson1")
    session = nil
    test_person = nil
    
    
    test_person = Person.find_by_username(username)
    unless test_person.present?
      test_person = FactoryGirl.build(:person, { :username => username, 
                      :password => "testi", 
                      :email => "#{username}@example.com",
                      :given_name => "Test",
                      :family_name => "Person"})
    end
  
    
    return [test_person, session]
  end
  
  def generate_random_username(length = 12)
    chars = ("a".."z").to_a + ("0".."9").to_a
    random_username = "aa_kassitest"
    1.upto(length - 7) { |i| random_username << chars[rand(chars.size-1)] }
    return random_username
  end
  
  def set_subdomain(subdomain = "test")
    subdomain += "." unless subdomain.blank?
    @request.host = "#{subdomain}.lvh.me"
  end
  
  def sign_in_for_spec(person)
    # For some reason only sign_in (Devise) doesn't work so 2 next lines to fix that
    #sign_in person
    request.env['warden'].stub :authenticate! => person
    controller.stub :current_person => person
  end
  
end
