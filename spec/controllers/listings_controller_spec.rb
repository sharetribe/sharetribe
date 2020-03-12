# == Schema Information
#
# Table name: listings
#
#  id                              :integer          not null, primary key
#  uuid                            :binary(16)       not null
#  community_id                    :integer          not null
#  author_id                       :string(255)
#  category_old                    :string(255)
#  title                           :string(255)
#  times_viewed                    :integer          default(0)
#  language                        :string(255)
#  created_at                      :datetime
#  updates_email_at                :datetime
#  updated_at                      :datetime
#  last_modified                   :datetime
#  sort_date                       :datetime
#  listing_type_old                :string(255)
#  description                     :text(65535)
#  origin                          :string(255)
#  destination                     :string(255)
#  valid_until                     :datetime
#  delta                           :boolean          default(TRUE), not null
#  open                            :boolean          default(TRUE)
#  share_type_old                  :string(255)
#  privacy                         :string(255)      default("private")
#  comments_count                  :integer          default(0)
#  subcategory_old                 :string(255)
#  old_category_id                 :integer
#  category_id                     :integer
#  share_type_id                   :integer
#  listing_shape_id                :integer
#  transaction_process_id          :integer
#  shape_name_tr_key               :string(255)
#  action_button_tr_key            :string(255)
#  price_cents                     :integer
#  currency                        :string(255)
#  quantity                        :string(255)
#  unit_type                       :string(32)
#  quantity_selector               :string(32)
#  unit_tr_key                     :string(64)
#  unit_selector_tr_key            :string(64)
#  deleted                         :boolean          default(FALSE)
#  require_shipping_address        :boolean          default(FALSE)
#  pickup_enabled                  :boolean          default(FALSE)
#  shipping_price_cents            :integer
#  shipping_price_additional_cents :integer
#  availability                    :string(32)       default("none")
#  per_hour_ready                  :boolean          default(FALSE)
#  state                           :string(255)      default("approved")
#  approval_count                  :integer          default(0)
#
# Indexes
#
#  community_author_deleted            (community_id,author_id,deleted)
#  index_listings_on_category_id       (old_category_id)
#  index_listings_on_community_id      (community_id)
#  index_listings_on_listing_shape_id  (listing_shape_id)
#  index_listings_on_new_category_id   (category_id)
#  index_listings_on_open              (open)
#  index_listings_on_state             (state)
#  index_listings_on_uuid              (uuid) UNIQUE
#  index_on_author_id_and_deleted      (author_id,deleted)
#  listings_homepage_query             (community_id,open,state,deleted,valid_until,sort_date)
#  listings_updates_email              (community_id,open,state,deleted,valid_until,updates_email_at,created_at)
#  person_listings                     (community_id,author_id)
#

#Tests LisingControllers atom feed feature

require 'spec_helper'

describe ListingsController, type: :controller do
  render_views

  before (:each) do
    Rails.cache.clear
  end

  let(:plan) do
    {
      expired: false,
      features: {
        whitelabel: true,
        admin_email: true,
        footer: false
      },
      created_at: Time.zone.now,
      updated_at: Time.zone.now
    }
  end

  def create_shape(community_id, type, process, translations = [], categories = [])
    defaults = TransactionTypeCreator::DEFAULTS[type][process.process] || TransactionTypeCreator::DEFAULTS[type]

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
        transaction_process_id: process.id,
        name_tr_key: name_tr_key,
        action_button_tr_key: 'admin.transaction_types.default_action_button_labels.sell',
        translations: translations_with_default,
        basename: Maybe(translations).first[:name].or_else(type)
      })

    ListingShape.create_with_opts(community: Community.find(community_id), opts: opts)
  end

  describe "ATOM feed" do
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

      request_shape    = create_shape(@c1.id, "Request", c1_request_process)
      sell_shape       = create_shape(@c1.id, "Sell",    c1_offer_process, [{locale: "fi", name: "Myydään"}], [@category_item, @category_furniture])
      create_shape(@c2.id, "Sell",    c2_offer_process)
      request_c2_shape = create_shape(@c2.id, "Request", c2_request_process)
      create_shape(@c1.id, "Service", c1_request_process)

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

      @l2 = FactoryGirl.create(
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

    it "lists the most recent listings in order" do
      get :index, params: { :format => :atom }
      expect(response.status).to eq(200)
      doc = Nokogiri::XML::Document.parse(response.body)
      doc.remove_namespaces!
      expect(doc.at('feed/logo').text).to eq("https://s3.amazonaws.com/sharetribe/assets/dashboard/sharetribe_logo.png")

      expect(doc.at("feed/title").text).to match(/Listings in Sharetribe /)
      expect(doc.search("feed/entry").count).to eq(2)
      expect(doc.search("feed/entry/title")[0].text).to eq("Sell: hammer")
      expect(doc.search("feed/entry/listing_id")[0].text).to eq(@l2.id.to_s)
      expect(doc.search("feed/entry/title")[1].text).to eq("Request: bike")
      expect(doc.search("feed/entry/listing_id")[1].text).to eq(@l1.id.to_s)
      expect(doc.search("feed/entry/published")[0].text).to be > doc.search("feed/entry/published")[1].text
      #DateTime.parse(doc.search("feed/entry/published")[1].text).should == @l1.created_at
      expect(doc.search("feed/entry/content")[1].text).to match(/#{@l1.description}/)

      expect(doc.at("feed/entry/listing_price").attribute("amount").value).to eq("0.20")
      expect(doc.at("feed/entry/listing_price").attribute("currency").value).to eq("USD")
      expect(doc.at("feed/entry/listing_price").attribute("unit").value).to eq("")
    end

    it "supports localization" do
      get :index, params: { :community_id => @c1.id, :format => :atom, :locale => "fi" }
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
      get :index, params: { :community_id => @c1.id, :format => :atom }
      expect(response.status).to eq(200)
      doc = Nokogiri::XML::Document.parse(response.body)
      expect(doc.at("feed/entry/content").text).to match(/&lt;b&gt;shiny&lt;\/b&gt; new hammer, see details at/)
      expect(doc.at("feed/entry/content").text).to match(/http:\/\/en\.wikipedia\.org\/wiki\/MC_Hammer<\/a>/)
    end
  end

  describe 'approval' do
    let(:community) { FactoryGirl.create(:community) }
    let(:offer_process) {
      FactoryGirl.create(:transaction_process,
                                               community_id: community.id,
                                               process: :none)
    }
    let(:sell_shape) { create_shape(community.id, "Sell", offer_process) }
    let(:person) { FactoryGirl.create(:person, member_of: community) }
    let(:listing) {
      FactoryGirl.create(:listing,
                         community_id: community.id,
                         author: person,
                         transaction_process_id: sell_shape[:transaction_process_id],
                         listing_shape_id: sell_shape[:id],
                         shape_name_tr_key: sell_shape[:name_tr_key],
                         action_button_tr_key: sell_shape[:action_button_tr_key]
                        )
    }
    let(:pending_listing) {
      FactoryGirl.create(:listing, community_id: community.id,
                                   author: person,
                                   state: Listing::APPROVAL_PENDING,
                                   transaction_process_id: sell_shape[:transaction_process_id],
                                   listing_shape_id: sell_shape[:id],
                                   shape_name_tr_key: sell_shape[:name_tr_key],
                                   action_button_tr_key: sell_shape[:action_button_tr_key]
                        )
    }
    let(:rejected_listing) {
      FactoryGirl.create(:listing, community_id: community.id,
                                   author: person,
                                   state: Listing::APPROVAL_REJECTED,
                                   transaction_process_id: sell_shape[:transaction_process_id],
                                   listing_shape_id: sell_shape[:id],
                                   shape_name_tr_key: sell_shape[:name_tr_key],
                                   action_button_tr_key: sell_shape[:action_button_tr_key]
                        )
    }
    let(:admin) { FactoryGirl.create(:person, member_of: community, member_is_admin: true) }

    before :each do
      @request.host = "#{community.ident}.lvh.me"
      @request.env[:current_marketplace] = community
      stub_thinking_sphinx
    end

    it 'If the community.pre_approved_listings is later disabled
        If a rejected or pending listing is edited, then it would automatically
        be opened (the pending status should not be assigned).' do
      sign_in_for_spec(person)
      patch :update, params: { id: pending_listing.id, listing: {
        title: 'Easy As Pie',
        listing_shape_id: pending_listing.listing_shape_id,
        price: "1.00",
        unit: "{\"unit_type\":\"unit\",\"kind\":\"quantity\",\"quantity_selector\":\"number\"}"
      }}
      pending_listing.reload
      expect(pending_listing.state).to eq Listing::APPROVED
    end

    it 'If the community.pre_approved_listings is on
        If a open listing is edited, then it would automatically
        should be assigned the pending status.
        Admin receives listing submited for review email.' do
      admin
      sign_in_for_spec(person)
      community.update_column(:pre_approved_listings, true)
      ActionMailer::Base.deliveries = []
      patch :update, params: { id: listing.id, listing: {
        title: 'Easy As Pie',
        listing_shape_id: listing.listing_shape_id,
        price: "1.00",
        unit: "{\"unit_type\":\"unit\",\"kind\":\"quantity\",\"quantity_selector\":\"number\"}"
      }}
      listing.reload
      expect(listing.state).to eq Listing::APPROVAL_PENDING

      process_jobs
      expect(ActionMailer::Base.deliveries).not_to be_empty
      email = ActionMailer::Base.deliveries.first
      expect(email.to.include?(admin.confirmed_notification_emails_to)).to eq true
      expect(email.subject).to eq 'Edited listing to review: "Easy As Pie" by Proto T in Sharetribe'
    end

    it 'If the community.pre_approved_listings is on
        If a pending listing is edited by admin, then it would automatically
        should be assigned the approved status.' do
      sign_in_for_spec(create_admin_for(community))
      community.update_column(:pre_approved_listings, true)
      patch :update, params: { id: pending_listing.id, listing: {
        title: 'Easy As Pie',
        listing_shape_id: pending_listing.listing_shape_id,
        price: "1.00",
        unit: "{\"unit_type\":\"unit\",\"kind\":\"quantity\",\"quantity_selector\":\"number\"}"
      }}
      pending_listing.reload
      expect(pending_listing.state).to eq Listing::APPROVED
    end

    it 'If the community.pre_approved_listings is on
        If a rejected listing is edited, then it would automatically
        should be assigned the pending status.
        Admin receives edited listing submited for review email.' do
      RequestStore.store[:feature_flags] = [:approve_listings].to_set
      admin
      sign_in_for_spec(person)
      community.update_column(:pre_approved_listings, true)
      ActionMailer::Base.deliveries = []
      patch :update, params: { id: rejected_listing.id, listing: {
        title: 'Easy As Pie',
        listing_shape_id: rejected_listing.listing_shape_id,
        price: "1.00",
        unit: "{\"unit_type\":\"unit\",\"kind\":\"quantity\",\"quantity_selector\":\"number\"}"
      }}
      rejected_listing.reload
      expect(rejected_listing.state).to eq Listing::APPROVAL_PENDING

      process_jobs
      expect(ActionMailer::Base.deliveries).not_to be_empty
      email = ActionMailer::Base.deliveries.first
      expect(email.to.include?(admin.confirmed_notification_emails_to)).to eq true
      expect(email.subject).to eq 'Edited listing to review: "Easy As Pie" by Proto T in Sharetribe'
    end

    it 'If the community.pre_approved_listings is on
        If a rejected listing is edited by admin, then it would automatically
        should be assigned the pending status.' do
      sign_in_for_spec(create_admin_for(community))
      community.update_column(:pre_approved_listings, true)
      patch :update, params: { id: rejected_listing.id, listing: {
        title: 'Easy As Pie',
        listing_shape_id: rejected_listing.listing_shape_id,
        price: "1.00",
        unit: "{\"unit_type\":\"unit\",\"kind\":\"quantity\",\"quantity_selector\":\"number\"}"
      }}
      rejected_listing.reload
      expect(rejected_listing.state).to eq Listing::APPROVED
    end

    it 'If the community.pre_approved_listings is on
      user creates listing, then it would automatically
        should be assigned the pending status.
        Admin receives listing submited for review email.' do
      admin
      sign_in_for_spec(person)
      community.update_column(:pre_approved_listings, true)
      valid_until = Time.current + 3.months
      ActionMailer::Base.deliveries = []
      post :create, params: {
        "listing" => {
          "title" => "Mock-Duck and Chard Pie served with Oscar Meyer Squash",
          "price" => "100",
          "shipping_price" => "0",
          "shipping_price_additional" => "0",
          "delivery_methods" => ["pickup"],
          "description" => "",
          "valid_until(1i)" => valid_until.year,
          "valid_until(2i)" => valid_until.month,
          "valid_until(3i)" => valid_until.day,
          "origin" => "",
          "origin_loc_attributes" => {"address"=>"", "google_address"=>"", "latitude"=>"", "longitude"=>""},
          "category_id" => "1",
          "listing_shape_id" => sell_shape[:id],
          "unit" => {:unit_type=>"unit", :kind=>"quantity"}.to_json
        }
      }
      listing = assigns(:listing)
      expect(listing.persisted?).to eq true
      expect(listing.state).to eq Listing::APPROVAL_PENDING

      process_jobs
      expect(ActionMailer::Base.deliveries).not_to be_empty
      email = ActionMailer::Base.deliveries.first
      expect(email.to.include?(admin.confirmed_notification_emails_to)).to eq true
      expect(email.subject).to eq 'New listing to review: "Mock-Duck and Chard Pie served with Oscar Meyer Squash" by Proto T in Sharetribe'
    end
  end

  describe "custom meta tags" do
    let(:community){ FactoryGirl.create(:community, :settings => {"locales" => ["en", "fi"]}) }
    let(:offer_process) {
      FactoryGirl.create(:transaction_process,
                                               community_id: community.id,
                                               process: :none)
    }
    let(:sell_shape) { create_shape(community.id, "Sell", offer_process) }
    let(:person) { FactoryGirl.create(:person, member_of: community) }
    let(:listing) {
      FactoryGirl.create(:listing,
                         community_id: community.id,
                         author: person,
                         transaction_process_id: sell_shape[:transaction_process_id],
                         listing_shape_id: sell_shape[:id],
                         shape_name_tr_key: sell_shape[:name_tr_key],
                         action_button_tr_key: sell_shape[:action_button_tr_key],
                         unit_type: 'hour',
                         title: "bike",
                         description: "A very nice bike",
                         price: Money.new(4567, "USD")
                        )
    }
    let(:listing_without_price) {
      FactoryGirl.create(:listing,
                         community_id: community.id,
                         author: person,
                         transaction_process_id: sell_shape[:transaction_process_id],
                         listing_shape_id: sell_shape[:id],
                         shape_name_tr_key: sell_shape[:name_tr_key],
                         action_button_tr_key: sell_shape[:action_button_tr_key],
                         unit_type: nil,
                         title: "Batman-s Top 10 Amazing Halo Tips",
                         description: "O lewd purpose! O unworthy merit! Thou art th' Lord's fair zeal.",
                         price_cents: 0
                        )
    }

    before :each do
      @request.host = "#{community.ident}.lvh.me"
      @request.env[:current_marketplace] = community
    end

    it "shows renders custom meta tags with placeholders" do
      community.community_customizations.first.update(listing_meta_title: "{{listing_title}} - {{marketplace_name}}", listing_meta_description: "{{listing_title}} for {{listing_price}} by {{listing_author}} in {{marketplace_name}}")
      get :show, params: {id: listing.id}
      expect(response.body).to match('<title>bike - Sharetribe</title>')
      expect(response.body).to match("<meta content='bike - Sharetribe' property='og:title'>")
      expect(response.body).to match("<meta content='bike - Sharetribe' name='twitter:title'>")
      expect(response.body).to match("<meta content='bike for \\$45.67 per hour by Proto T in Sharetribe' name='description'>")
      expect(response.body).to match("<meta content='bike for \\$45.67 per hour by Proto T in Sharetribe' name='twitter:description'>")
      expect(response.body).to match("<meta content='bike for \\$45.67 per hour by Proto T in Sharetribe' property='og:description'>")
    end

    it "shows renders custom meta tags with placeholders
      for listing without price" do
      get :show, params: {id: listing_without_price.id}
      expect(response.body).to match("<title>Batman-s Top 10 Amazing Halo Tips - Sharetribe</title>")
      expect(response.body).to match("<meta content='Batman-s Top 10 Amazing Halo Tips - Sharetribe' property='og:title'>")
      expect(response.body).to match("<meta content='Batman-s Top 10 Amazing Halo Tips - Sharetribe' name='twitter:title'>")
      expect(response.body).to match("<meta content='Batman-s Top 10 Amazing Halo Tips by Proto T on Sharetribe' name='description'>")
      expect(response.body).to match("<meta content='Batman-s Top 10 Amazing Halo Tips by Proto T on Sharetribe' name='twitter:description'>")
      expect(response.body).to match("<meta content='Batman-s Top 10 Amazing Halo Tips by Proto T on Sharetribe' property='og:description'>")
    end
  end

  describe "delete" do
    let(:community){ FactoryGirl.create(:community, :settings => {"locales" => ["en", "fi"]}) }
    let(:offer_process) {
      FactoryGirl.create(:transaction_process,
                                               community_id: community.id,
                                               process: :none)
    }
    let(:sell_shape) { create_shape(community.id, "Sell", offer_process) }
    let(:person) { FactoryGirl.create(:person, member_of: community) }
    let(:listing) {
      FactoryGirl.create(:listing,
                         community_id: community.id,
                         author: person,
                         transaction_process_id: sell_shape[:transaction_process_id],
                         listing_shape_id: sell_shape[:id],
                         shape_name_tr_key: sell_shape[:name_tr_key],
                         action_button_tr_key: sell_shape[:action_button_tr_key],
                         unit_type: 'hour',
                         title: "bike",
                         description: "A very nice bike",
                         price: Money.new(4567, "USD")
                        )
    }

    before :each do
      @request.host = "#{community.ident}.lvh.me"
      @request.env[:current_marketplace] = community
    end

    it 'author deletes listing' do
      sign_in_for_spec(person)
      delete :delete, params: {id: listing.id}
      listing.reload
      expect(listing.deleted).to eq true
    end
  end
end
