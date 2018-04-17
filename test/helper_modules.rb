# Modules in this file are included in both specs and cucumber steps.

module TestHelpers
  module CategoriesHelper

    DEFAULT_LISTING_SHAPE_TEMPLATES_FOR_TESTS = {
      Sell: {
        en: {
          name: "Selling", action_button_label: "Buy this item"
        }
      },
      Lend: {
        en: {
          name: "Lending", action_button_label: "Borrow this item"
        }
      },
      Rent: {
        en: {
          name: "Renting", action_button_label: "Rent this item"
        }
      },
      Request: {
        en: {
          name: "Requesting", action_button_label: "Offer"
        }
      },
      Service: {
        en: {
          name: "Selling services", action_button_label: "Offer"
        }
      }
    }

    DEFAULT_CATEGORIES_FOR_TESTS = [
      {
      "item" => [
        "tools",
        "books"
        ]
      },
      "favor",
      "housing"
    ]

    def self.load_test_categories_and_listing_shapes_to_db(community)
      TestHelpers::CategoriesHelper.load_categories_and_listing_shapes_to_db(community, DEFAULT_LISTING_SHAPE_TEMPLATES_FOR_TESTS, DEFAULT_CATEGORIES_FOR_TESTS)
    end

    def self.load_categories_and_listing_shapes_to_db(community, listing_shape_templates, categories)
      processes = [:none, :preauthorize, :postpay].inject({}) { |memo, process|
        memo.tap { |m|
          process_res = TransactionService::API::Api.processes.create(
            community_id: community.id,
            process: process,
            author_is_seller: true
          )

          memo[process] = process_res.data[:id]
        }
      }

      # Load listing shapes
      listing_shape_templates.each do |type, translations|
        name_group = {
          translations: community.locales.map do |locale|
            translation = translations[locale.to_sym]
            {locale: locale, translation: translation[:name]} unless translation.blank?
          end.compact
        }
        ab_group = {
          translations: community.locales.map do |locale|
            translation = translations[locale.to_sym]
            {locale: locale, translation: translation[:action_button_label]} unless translation.blank?
          end.compact
        }
        created_translations = TranslationService::API::Api.translations.create(community.id, [name_group, ab_group])
        name_tr_key, action_button_tr_key = created_translations[:data].map { |translation| translation[:translation_key] }

        translations = community.locales.map do |locale|
          translation = translations[locale.to_sym]

          if translation
            {
              locale: locale,
              name: translation[:name],
              action_button_label: translation[:action_button_label]
            }
          end
        end.compact

        basename = translations.find{ |t| t[:locale] == community.default_locale }[:name]

        defaults = TransactionTypeCreator::DEFAULTS[type.to_s][:none] || TransactionTypeCreator::DEFAULTS[type.to_s]
        shape_opts = defaults.merge(
          transaction_process_id: processes[:none],
          translations: translations,
          name_tr_key: name_tr_key,
          action_button_tr_key: action_button_tr_key,
          shipping_enabled: false,
          basename: basename
        )

        ListingShape.create_with_opts(community: community, opts: shape_opts)
      end

      # Community has now new listing shapes, so we must reload it
      community.reload

      # Load categories
      categories.each do |c|

        # Categories that do not have subcategories
        if c.is_a?(String)
          category = Category.create!(:community_id => community.id)
          TestHelpers::CategoriesHelper.add_listing_shapes_and_translations_to_category(category, c)

        # Categories that have subcategories
        elsif c.is_a?(Hash)
          top_level_category = Category.create!(:community_id => community.id)
          TestHelpers::CategoriesHelper.add_listing_shapes_and_translations_to_category(top_level_category, c.keys.first)
          c.values.first.each do |sg|
            subcategory = Category.create!(:community_id => community.id, :parent_id => top_level_category.id)
            TestHelpers::CategoriesHelper.add_listing_shapes_and_translations_to_category(subcategory, sg)
          end
        end

      end
    end

    def self.add_listing_shapes_and_translations_to_category(category, category_name)
      category.community.shapes.each do |s|
        CategoryListingShape.create!(category_id: category.id, listing_shape_id: s[:id])
      end

      category.community.locales.each do |locale|
        cat_name = I18n.t!(category_name, :locale => locale, :scope => ["common", "categories"], :raise => true)
        category.translations.create!(:locale => locale, :name => cat_name)
      end
    end
  end

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

  def generate_random_username(length = 12)
    chars = ("a".."z").to_a + ("0".."9").to_a
    random_username = "aa_kassitest"
    1.upto(length - 7) { |i| random_username << chars[rand(chars.size-1)] }
    return random_username
  end

  def sign_in_for_spec(person)
    allow(request.env['warden']).to receive_messages(authenticate!: person)
    allow(controller).to receive_messages(current_person: person)
  end

  def find_or_build_category(category_name)
    TestHelpers::find_category_by_name(category_name) || FactoryGirl.build(:category)
  end

  module_function :find_or_build_category

  def find_category_by_name(category_name)
    Category.all.select do |category|
      category.display_name("en") == category_name
    end.first
  end

  module_function :find_category_by_name

  def find_numeric_custom_field_type_by_name(name)
    NumericField.all.select do |numeric_custom_field|
      numeric_custom_field.name("en") == name
    end.first
  end

  def index_finished?
    Dir[Rails.root.join(ThinkingSphinx::Test.config.indices_location, '*.{new,tmp}.*')].empty?
  end

  def wait_until_index_finished
    sleep 0.25 until index_finished?
  end

  def ensure_sphinx_is_running_and_indexed
    begin
      Listing.search("").total_pages
    rescue ThinkingSphinx::ConnectionError
      # Sphinx was not running so start it for this session
      ThinkingSphinx::Test.init
      ThinkingSphinx::Test.start_with_autostop
    end
    ThinkingSphinx::Test.index
    wait_until_index_finished()
  end

  # This is loaded only once before running the whole test set
  def load_default_test_data_to_db_before_suite
    community1 = FactoryGirl.create(:community, :ident => "test", :consent => "test_consent0.1", :settings => {"locales" => ["en", "fi"]}, :real_name_required => true)
    community1.community_customizations.create(name: "Sharetribe", locale: "fi")
    community2 = FactoryGirl.create(:community, :ident => "test2", :consent => "KASSI_FI1.0", :settings => {"locales" => ["en"]}, :real_name_required => true, :allowed_emails => "@example.com")
    community3 = FactoryGirl.create(:community, :ident => "test3", :consent => "KASSI_FI1.0", :settings => {"locales" => ["en"]}, :real_name_required => true)

    [community1, community2, community3].each { |c| TestHelpers::CategoriesHelper.load_test_categories_and_listing_shapes_to_db(c) }
  end
  module_function :load_default_test_data_to_db_before_suite

  # This is loaded before each test
  def load_default_test_data_to_db_before_test
    community1 = Community.where(ident: "test").first
    community2 = Community.where(ident: "test2").first
    community3 = Community.where(ident: "test3").first

    person1 = FactoryGirl.create(:person,
                                 community_id: community1.id,
                                 username: "kassi_testperson1",
                                 emails: [
                                   FactoryGirl.build(:email, community_id: community1.id, :address => "kassi_testperson3@example.com") ],
                                 is_admin: 0,
                                 locale: "en",
                                 encrypted_password: "$2a$10$WQHcobA3hrTdSDh1jfiMquuSZpM3rXlcMU71bhE1lejzBa3zN7yY2", #"testi"
                                 given_name: "Kassi",
                                 family_name: "Testperson1",
                                 phone_number: "0000-123456",
                                 created_at: "2012-05-04 18:17:04")

    person2 = FactoryGirl.create(:person,
                                 community_id: community1.id,
                                 username: "kassi_testperson2",
                                 emails: [
                                   FactoryGirl.build(:email, community_id: community1.id, :address => "kassi_testperson4@example.com") ],
                                 is_admin: false,
                                 locale: "en",
                                 encrypted_password: "$2a$10$WQHcobA3hrTdSDh1jfiMquuSZpM3rXlcMU71bhE1lejzBa3zN7yY2", #"testi"
                                 given_name: "Kassi",
                                 family_name: "Testperson2",
                                 created_at: "2012-05-04 18:17:04")

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

    FactoryGirl.create(:marketplace_configurations,
                      community_id: community1.id,
                      main_search: "keyword",
                      distance_unit: "metric",
                      limit_search_distance: 0)

  end
  module_function :load_default_test_data_to_db_before_test

end
