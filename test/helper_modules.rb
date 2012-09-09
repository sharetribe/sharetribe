# Modules in this file are included in both specs and cucumber steps.

module TestHelpers
  
  def create_listing(listing_type, category, share_type)
    listing_params = {:category => category}
    if category
      case category
      when "favor"
       # listing = Factory(:listing, :category => category, :share_type => nil, :listing_type => listing_type)
        listing_params.merge!({ :share_type => nil, :listing_type => listing_type})
      when "rideshare"
        #listing = Factory(:listing, :category => category, :share_type => nil, :origin => "test", :destination => "test2", :listing_type => listing_type)
        listing_params.merge!({:share_type => nil, :origin => "test", :destination => "test2", :listing_type => listing_type})
      else
        if share_type.nil? && ["item", "housing"].include?(category)
          share_type = listing_type.eql?("request") ? "buy" : "sell"
        end
        #listing = Factory(:listing, :category => category, :share_type => share_type, :listing_type => listing_type)
        listing_params.merge!({ :share_type => share_type, :listing_type => listing_type})
      end
    else
      #listing = Factory(:listing, :category => "item")
      listing_params[:category] = "item"
    end
    
    if not use_asi?
       # set author manually as factory doesn't default to kassi_testperson1
       test_person, session = get_test_person_and_session
       listing_params.merge!({:author => test_person})
    end
    
    listing = Factory(:listing, listing_params)
  end
  
  def get_test_person_and_session(username="kassi_testperson1")
    session = nil
    test_person = nil
    if ApplicationHelper::use_asi?
      #frist try loggin in to cos
      begin
        session = Session.create({:username => username, :password => "testi" })
        #try to find in kassi database
        test_person = Person.find(session.person_id)

      rescue RestClient::Request::Unauthorized => e
        #if not found, create completely new
        session = Session.create
        test_person = Person.create({ :username => username, 
                        :password => "testi", 
                        :email => "#{username}@example.com",
                        :given_name => "Test",
                        :family_name => "Person"},  
                         session.cookie)

      rescue ActiveRecord::RecordNotFound  => e
        test_person = Person.add_to_kassi_db(session.person_id)
      end
    
    else # No ASI just Sharetribe DB in use
      test_person = Person.find_by_username(username)
      unless test_person.present?
        test_person = FactoryGirl.build(:person, { :username => username, 
                        :password => "testi", 
                        :email => "#{username}@example.com",
                        :given_name => "Test",
                        :family_name => "Person"})
      end
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
  
end
