# Modules in this file are included in both specs and cucumber steps.

module TestHelpers

  # http://pullmonkey.com/2008/01/06/convert-a-ruby-hash-into-a-class-object/
  class HashClass
    def initialize(hash)
      hash.each do |k,v|
        self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
        self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
        self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
      end
    end
  end
  
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
                      :emails => [ FactoryGirl.create(:email, :address => "#{username}@example.com" ) ],
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

  def ensure_sphinx_is_running_and_indexed
    begin 
      Listing.search("").total_pages
    rescue Mysql2::Error => e
      # Sphinx was not running so start it for this session
      ThinkingSphinx::Test.init
      ThinkingSphinx::Test.start_with_autostop
    end
    ThinkingSphinx::Test.index
    # Wait for Sphinx to finish loading in the new index files.
    sleep 0.25
    
  end

  # This is loaded only once before running the whole test set
  def load_default_test_data_to_db_before_tests
    # Remove persistent data in case there is any
    DatabaseCleaner.clean_with(:truncation)

    community1 = FactoryGirl.create(:community, :domain => "test", :name => "Test", :consent => "test_consent0.1", :settings => {"locales" => ["en", "fi"]}, :real_name_required => true, :news_enabled => false, :all_users_can_add_news => false)
    community2 = FactoryGirl.create(:community, :domain => "test2", :name => "Test2", :consent => "KASSI_FI1.0", :settings => {"locales" => ["en"]}, :real_name_required => true, :allowed_emails => "@example.com")
    community3 = FactoryGirl.create(:community, :domain => "test3", :name => "Test3", :consent => "KASSI_FI1.0", :settings => {"locales" => ["en"]}, :real_name_required => true)

    [community1, community2, community3].each { |c| CategoriesHelper.load_test_categories_and_transaction_types_to_db(c) }
  end

  # This is loaded before each test
  def load_default_test_data_to_db_before_test
    community1 = Community.find_by_domain("test")
    community2 = Community.find_by_domain("test2")
    community3 = Community.find_by_domain("test3")
    
    person1 = FactoryGirl.create(:person, :username => "kassi_testperson1", :is_admin => 0, "locale" => "en", :encrypted_password => "64ae669314a3fb4b514fa5607ef28d3e1c1937a486e3f04f758270913de4faf5", :password_salt => "vGpGrfvaOhp3", :given_name => "Kassi", :family_name => "Testperson1", :phone_number => "0000-123456", :created_at => "2012-05-04 18:17:04")
    person2 = FactoryGirl.create(:person, :username => "kassi_testperson2", :is_admin => false, :locale => "en", :encrypted_password => "72bf5831e031cbcf2e226847677fccd6d8ec6fe0673549a60abb5fd05f726462", :password_salt => "zXklAGLwt7Cu", :given_name => "Kassi", :family_name => "Testperson2", :created_at => "2012-05-04 18:17:04")

    FactoryGirl.create(:community_membership, :person => person1,
                        :community => community1,
                        :admin => 1,
                        :consent => "test_consent0.1",
                        :last_page_load_date => DateTime.now,
                        :status => "accepted" )

    FactoryGirl.create(:community_membership, :person => person2,
                      :community=> community1,
                      :admin => 0,
                      :consent => "test_consent0.1",
                      :last_page_load_date => DateTime.now,
                      :status => "accepted")

    FactoryGirl.create(:community_membership, :person => person2,
                      :community => community2,
                      :admin => 0,
                      :consent => "KASSI_FI1.0",
                      :last_page_load_date => DateTime.now,
                      :status => "accepted")

    FactoryGirl.create(:email,
    :person => person1,
    :address => "kassi_testperson1@example.com",
    :send_notifications => true,
    :confirmed_at => "2012-05-04 18:17:04")

    FactoryGirl.create(:email,
    :person => person2,
    :address => "kassi_testperson2@example.com",
    :send_notifications => true,
    :confirmed_at => "2012-05-04 18:17:04")

  end

end
