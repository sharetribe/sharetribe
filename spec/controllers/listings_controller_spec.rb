# encoding: utf-8

#Tests LisingControllers atom feed feature

require 'spec_helper'

describe ListingsController, type: :controller do
  render_views

  before (:each) do
    Rails.cache.clear
  end

  def create_shape(community_id, type, process_id, translations = [], categories = [])
    listings_api = ListingService::API::Api

    defaults = TransactionTypeCreator::DEFAULTS[type]

    # Save name to TranslationService
    translations_with_default = translations.concat([{ locale: "en", name: type }])
    name_group = {
      translations: translations_with_default.map { |translation|
          { locale: translation[:locale],
            translation: translation[:name]
          }
        }
      }
    created_translations = TranslationService::API::Api.translations.create(community_id, [name_group])
    name_tr_key = created_translations[:data].map { |translation| translation[:translation_key] }.first

    opts = defaults.merge(
      {
        shipping_enabled: false,
        transaction_process_id: process_id,
        name_tr_key: name_tr_key,
        action_button_tr_key: 'something.here',
        translations: translations_with_default,
        basename: Maybe(translations).first[:name].or_else(type)
      })

    listings_api.shapes.create(community_id: community_id, opts: opts).data
  end

  before(:each) do
    Listing.all.collect(&:destroy) # for some reason there's a listing before starting. Destroy to be clear.

    @c1 = FactoryGirl.create(:community, :settings => {"locales" => ["en", "fi"]})
    @c1.community_customizations << FactoryGirl.create(:community_customization, :locale => "fi")
    @c2 = FactoryGirl.create(:community)

    @p1 = FactoryGirl.create(:person)
    @p1.accepted_community = @c1

    @category_item      = FactoryGirl.create(:category, :community => @c1)
    @category_item.translations << FactoryGirl.create(:category_translation, :name => "Tavarat", :locale => "fi", :category => @category_item)
    @category_favor     = FactoryGirl.create(:category, :community => @c1)
    @category_rideshare = FactoryGirl.create(:category, :community => @c1)
    @category_furniture = FactoryGirl.create(:category, :community => @c1)

    c1_request_process = TransactionProcess.create(community_id: @c1.id, process: :none, author_is_seller: false)
    c1_offer_process   = TransactionProcess.create(community_id: @c1.id, process: :none, author_is_seller: true)
    c2_request_process = TransactionProcess.create(community_id: @c2.id, process: :none, author_is_seller: false)
    c2_offer_process   = TransactionProcess.create(community_id: @c2.id, process: :none, author_is_seller: true)

    request_shape    = create_shape(@c1.id, "Request", c1_request_process.id)
    sell_shape       = create_shape(@c1.id, "Sell",    c1_offer_process.id, [{locale: "fi", name: "Myydään"}], [@category_item, @category_furniture])
    sell_c2_shape    = create_shape(@c2.id, "Sell",    c2_offer_process.id)
    request_c2_shape = create_shape(@c2.id, "Request", c2_request_process.id)
    service_shape    = create_shape(@c1.id, "Service", c1_request_process.id)

    # This is needed in the spec, thus save it in instance variable
    @sell_shape = sell_shape

    @l1 = FactoryGirl.create(
      :listing,
      :transaction_process_id => request_shape[:transaction_process_id],
      :listing_shape_id => request_shape[:id],
      :shape_name_tr_key => request_shape[:name_tr_key],
      :action_button_tr_key => request_shape[:action_button_tr_key],
      :title => "bike",
      :description => "A very nice bike",
      :created_at => 3.days.ago,
      :sort_date => 3.days.ago,
      :author => @p1,
      :community_id => @c1.id,
    )

    FactoryGirl.create(
      :listing,
      :title => "hammer",
      :category => @category_item,
      :created_at => 2.days.ago,
      :sort_date => 2.days.ago,
      :description => "<b>shiny</b> new hammer, see details at http://en.wikipedia.org/wiki/MC_Hammer",
      :transaction_process_id => sell_shape[:transaction_process_id],
      :listing_shape_id => sell_shape[:id],
      :shape_name_tr_key => sell_shape[:name_tr_key],
      :action_button_tr_key => sell_shape[:action_button_tr_key],
      :community_id => @c1.id,
    )

    FactoryGirl.create(
      :listing,
      :transaction_process_id => request_c2_shape[:transaction_process_id],
      :listing_shape_id => request_c2_shape[:id],
      :shape_name_tr_key => request_c2_shape[:name_tr_key],
      :action_button_tr_key => request_c2_shape[:action_button_tr_key],
      :title => "help me",
      :created_at => 12.days.ago,
      :sort_date => 12.days.ago,
      :community_id => @c2.id,
    )

    FactoryGirl.create(
      :listing,
      :transaction_process_id => request_shape[:transaction_process_id],
      :listing_shape_id => request_shape[:id],
      :shape_name_tr_key => request_shape[:name_tr_key],
      :action_button_tr_key => request_shape[:action_button_tr_key],
      :title => "old junk",
      :open => false,
      :description => "This should be closed already,
 but nice stuff anyway",
      :community_id => @c1.id,
    )

    @l4 = FactoryGirl.create(
      :listing,
      :title => "car",
      :created_at => 2.months.ago,
      :sort_date => 2.months.ago,
      :description => "I needed a car earlier,
 but now this listing is no more open",
      :transaction_process_id => request_shape[:transaction_process_id],
      :listing_shape_id => request_shape[:id],
      :shape_name_tr_key => request_shape[:name_tr_key],
      :action_button_tr_key => request_shape[:action_button_tr_key],
      :community_id => @c1.id,
    )
    @l4.save!
    @l4.update_attribute(:valid_until, 2.days.ago)

    @request.host = "#{@c1.ident}.lvh.me"
    @request.env[:current_marketplace] = @c1
  end

  describe "ATOM feed" do
    it "lists the most recent listings in order" do
      get :index, :format => :atom
      expect(response.status).to eq(200)
      doc = Nokogiri::XML::Document.parse(response.body)
      expect(doc.at('feed/logo').text).to eq("https://s3.amazonaws.com/sharetribe/assets/dashboard/sharetribe_logo.png")

      expect(doc.at("feed/title").text).to match(/Listings in Sharetribe /)
      expect(doc.search("feed/entry").count).to eq(2)
      expect(doc.search("feed/entry/title")[0].text).to eq("Sell: hammer")
      expect(doc.search("feed/entry/title")[1].text).to eq("Request: bike")
      expect(doc.search("feed/entry/published")[0].text).to be > doc.search("feed/entry/published")[1].text
      #DateTime.parse(doc.search("feed/entry/published")[1].text).should == @l1.created_at
      expect(doc.search("feed/entry/content")[1].text).to match(/#{@l1.description}/)
    end

    it "supports localization" do
      get :index, :community_id => @c1.id, :format => :atom, :locale => "fi"
      expect(response.status).to eq(200)
      doc = Nokogiri::XML::Document.parse(response.body)
      doc.remove_namespaces!

      expect(doc.at("feed/title").text).to match(/Ilmoitukset Sharetribe-palvelussa/)
      expect(doc.at("feed/entry/title").text).to eq("Myydään: hammer")
      expect(doc.at("feed/entry/category").attribute("term").value).to eq("#{@category_item.id}")
      expect(doc.at("feed/entry/category").attribute("label").value).to eq("Tavarat")
      expect(doc.at("feed/entry/listing_type").attribute("term").value).to eq("offer")
      expect(doc.at("feed/entry/listing_type").attribute("label").value).to eq("Tarjous")
      expect(doc.at("feed/entry/share_type").attribute("term").value).to eq("#{@sell_shape[:id]}")
      expect(doc.at("feed/entry/share_type").attribute("label").value).to eq("Myydään")
    end

    it "escapes html tags, but adds links" do
      get :index, :community_id => @c1.id, :format => :atom
      expect(response.status).to eq(200)
      doc = Nokogiri::XML::Document.parse(response.body)
      expect(doc.at("feed/entry/content").text).to match(/&lt;b&gt;shiny&lt;\/b&gt; new hammer, see details at/)
      expect(doc.at("feed/entry/content").text).to match(/http:\/\/en\.wikipedia\.org\/wiki\/MC_Hammer<\/a>/)
    end
  end
end
