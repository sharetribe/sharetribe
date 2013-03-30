# Modules in this file are included in both specs and cucumber steps.

module TestHelpers
  
  def create_listing(category, share_type)
    listing_params = {}
    
    if category
      listing_params.merge!({:category => find_or_create_category(category)})
      if category.eql? "rideshare"
        listing_params.merge!({:origin => "test", :destination => "test2"})
      end
    else
      listing_params[:category] = find_or_create_category("item")
    end
    
    if share_type
      listing_params.merge!({:share_type => find_or_create_share_type(share_type)})
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
  
  def find_or_create_category(category_name)
    Category.find_by_name(category_name) || FactoryGirl.create(:category, :name => category_name)
  end
  
  def find_or_create_share_type(share_type_name)
    return nil if share_type_name.blank?
    ShareType.find_by_name(share_type_name) || FactoryGirl.create(:share_type, :name => share_type_name)
  end
  
  def reset_categories_to_default
    ShareType.destroy_all #Without this there were some strange entries in the DB without correct parents
    Category.destroy_all
    CommunityCategory.destroy_all
    CategoriesHelper.load_default_categories_to_db
  end
  
  
end
