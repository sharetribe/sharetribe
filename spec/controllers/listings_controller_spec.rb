# encoding: utf-8

#Tests LisingControllers atom feed feature

require 'spec_helper'

describe ListingsController do
  render_views

  before (:each) do
    Rails.cache.clear
  end

  def create_transaction_type(community_id, type, process_id, translations = [], categories = [])
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
        url_source: Maybe(translations).first[:name].or_else(type)
      })

    shape = listings_api.shapes.create(community_id: community_id, opts: opts).data

    TransactionType.find(shape[:transaction_type_id])
  end

  before(:each) do
    Listing.all.collect(&:destroy) # for some reason there's a listing before starting. Destroy to be clear.

    @c1 = FactoryGirl.create(:community, :settings => {"locales" => ["en", "fi"]})
    @c1.community_customizations << FactoryGirl.create(:community_customization, :locale => "fi")
    @c2 = FactoryGirl.create(:community)

    @p1 = FactoryGirl.create(:person)
    @p1.communities << @c1
    @p1.ensure_authentication_token!

    @category_item      = FactoryGirl.create(:category, :community => @c1)
    @category_item.translations << FactoryGirl.create(:category_translation, :name => "Tavarat", :locale => "fi", :category => @category_item)
    @category_favor     = FactoryGirl.create(:category, :community => @c1)
    @category_rideshare = FactoryGirl.create(:category, :community => @c1)
    @category_furniture = FactoryGirl.create(:category, :community => @c1)

    c1_request_process = TransactionProcess.create(community_id: @c1.id, process: :none, author_is_seller: false)
    c1_offer_process   = TransactionProcess.create(community_id: @c1.id, process: :none, author_is_seller: true)
    c2_request_process = TransactionProcess.create(community_id: @c2.id, process: :none, author_is_seller: false)
    c2_offer_process   = TransactionProcess.create(community_id: @c2.id, process: :none, author_is_seller: true)

    @transaction_type_request       = create_transaction_type(@c1.id, "Request", c1_request_process.id)
    @transaction_type_sell          = create_transaction_type(@c1.id, "Sell",    c1_offer_process.id, [{locale: "fi", name: "Myydään"}], [@category_item, @category_furniture])
    @transaction_type_sell_c2       = create_transaction_type(@c2.id, "Sell",    c2_offer_process.id)
    @transaction_type_request_c2    = create_transaction_type(@c2.id, "Request", c2_request_process.id)
    @transaction_type_service_offer = create_transaction_type(@c1.id, "Service", c1_request_process.id)

    @l1 = FactoryGirl.create(:listing, :transaction_type => @transaction_type_request, :title => "bike", :description => "A very nice bike", :created_at => 3.days.ago, :sort_date => 3.days.ago, :author => @p1, :privacy => "public")
    @l1.communities = [@c1]
    FactoryGirl.create(:listing, :title => "hammer", :category => @category_item, :created_at => 2.days.ago, :sort_date => 2.days.ago, :description => "<b>shiny</b> new hammer, see details at http://en.wikipedia.org/wiki/MC_Hammer", :transaction_type => @transaction_type_sell, :privacy => "public").communities = [@c1]
    FactoryGirl.create(:listing, :transaction_type => @transaction_type_request_c2, :title => "help me", :created_at => 12.days.ago, :sort_date => 12.days.ago, :privacy => "public").communities = [@c2]
    FactoryGirl.create(:listing, :transaction_type => @transaction_type_request, :title => "old junk", :open => false, :description => "This should be closed already, but nice stuff anyway", :privacy => "public").communities = [@c1]
    @l4 = FactoryGirl.create(:listing, :title => "car", :created_at => 2.months.ago, :sort_date => 2.months.ago, :description => "I needed a car earlier, but now this listing is no more open", :transaction_type => @transaction_type_request, :privacy => "public")
    @l4.communities = [@c1]
    @l4.save!
    @l4.update_attribute(:valid_until, 2.days.ago)

    @request.host = "#{@c1.ident}.lvh.me"
  end

  describe "ATOM feed" do
    it "lists the most recent listings in order" do
      get :index, :format => :atom
      response.status.should == 200
      doc = Nokogiri::XML::Document.parse(response.body)
      doc.at('feed/logo').text.should == "https://s3.amazonaws.com/sharetribe/assets/dashboard/sharetribe_logo.png"

      doc.at("feed/title").text.should =~ /Listings in Sharetribe /
      doc.search("feed/entry").count.should == 2
      doc.search("feed/entry/title")[0].text.should == "Sell: hammer"
      doc.search("feed/entry/title")[1].text.should == "Request: bike"
      doc.search("feed/entry/published")[0].text.should > doc.search("feed/entry/published")[1].text
      #DateTime.parse(doc.search("feed/entry/published")[1].text).should == @l1.created_at
      doc.search("feed/entry/content")[1].text.should =~ /#{@l1.description}/
    end

    it "supports localization" do
      get :index, :community_id => @c1.id, :format => :atom, :locale => "fi"
      response.status.should == 200
      doc = Nokogiri::XML::Document.parse(response.body)
      doc.remove_namespaces!

      doc.at("feed/title").text.should =~ /Ilmoitukset Sharetribe-palvelussa/
      doc.at("feed/entry/title").text.should == "Myydään: hammer"
      doc.at("feed/entry/category").attribute("term").value.should == "#{@category_item.id}"
      doc.at("feed/entry/category").attribute("label").value.should == "Tavarat"
      doc.at("feed/entry/listing_type").attribute("term").value.should == "offer"
      doc.at("feed/entry/listing_type").attribute("label").value.should == "Tarjous"
      doc.at("feed/entry/share_type").attribute("term").value.should == "#{@transaction_type_sell.id}"
      doc.at("feed/entry/share_type").attribute("label").value.should == "Myydään"
    end

    # Commented out as requires sphinx and that caused some problems in test
    # that we didn't fix now as we might soon change the search engine
    # it "supports fliter parameters" do
    #   get :index, :community_id => @c1.id, :format => :atom, :share_type => "request", :locale => "en"
    #   response.status.should == 200
    #   doc = Nokogiri::XML::Document.parse(response.body)
    #   doc.search("feed/entry").count.should == 1
    #   doc.at("feed/entry/title").text.should == "Buying: bike"
    # end

    it "escapes html tags, but adds links" do
      get :index, :community_id => @c1.id, :format => :atom
      response.status.should == 200
      doc = Nokogiri::XML::Document.parse(response.body)
      doc.at("feed/entry/content").text.should =~ /&lt;b&gt;shiny&lt;\/b&gt; new hammer, see details at <a href="http:\/\/en\.wikipedia\.org\/wiki\/MC_Hammer" class=\"truncated-link\">http:\/\/en\.wikipedia\.org\/wiki\/MC_Hammer<\/a>/
    end

    # TODO: fix search tests after sphinx upgraded (or changed)
    # it "supports search" do
    #   get :index, :community_id => @c1.id, :format => :atom, :search => "hammer"
    #   response.status.should == 200
    #   doc = Nokogiri::XML::Document.parse(response.body)
    #   doc.search("feed/entry").count.should == 1
    #   doc.at("feed/entry/title").text.should == "Selling: hammer"
    # end

  end
end
