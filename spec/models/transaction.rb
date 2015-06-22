# tests the Transaction Model

# == Schema Information
#
# Table name: transactions
#
#  id                                :integer          not null, primary key
#  starter_id                        :string(255)      not null
#  listing_id                        :integer          not null
#  conversation_id                   :integer
#  automatic_confirmation_after_days :integer          not null
#  community_id                      :integer          not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  starter_skipped_feedback          :boolean          default(FALSE)
#  author_skipped_feedback           :boolean          default(FALSE)
#  last_transition_at                :datetime
#  current_state                     :string(255)
#  commission_from_seller            :integer
#  minimum_commission_cents          :integer          default(0)
#  minimum_commission_currency       :string(255)
#  payment_gateway                   :string(255)      default("none"), not null
#  listing_quantity                  :integer          default(1)
#  listing_author_id                 :string(255)
#  listing_title                     :string(255)
#  unit_type                         :string(32)
#  unit_price_cents                  :integer
#  unit_price_currency               :string(8)
#  unit_tr_key                       :string(64)
#  unit_selector_tr_key              :string(64)
#  payment_process                   :string(31)       default("none")
#  delivery_method                   :string(31)       default("none")
#  shipping_price_cents              :integer
#
# Indexes
#
#  index_transactions_on_community_id        (community_id)
#  index_transactions_on_conversation_id     (conversation_id)
#  index_transactions_on_last_transition_at  (last_transition_at)
#  index_transactions_on_listing_id          (listing_id)
#

require 'spec_helper'

describe Transaction do
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
    
    opts = defaults.merge({
      shipping_enabled: false,
      transaction_process_id: process_id,
      name_tr_key: name_tr_key,
      action_button_tr_key: 'something.here',
      translations: translations_with_default,
      basename: Maybe(translations).first[:name].or_else(type)
    })
    
    listings_api.shapes.create(community_id: community_id, opts: opts).data
  end
  
  before(:all) do
    Listing.all.collect(&:destroy) # for some reason there's a listing before starting. Destroy to be clear.
    
    @community = FactoryGirl.create(:community)
    
    @person1 = FactoryGirl.create(:person)
    @person1.communities << @community
    @person1.ensure_authentication_token!
    
    @person2 = FactoryGirl.create(:person)
    @person2.communities << @community
    @person2.ensure_authentication_token!
    
    request_process = TransactionProcess.create(community_id: @community.id, process: :none, author_is_seller: false)
    offer_process   = TransactionProcess.create(community_id: @community.id, process: :none, author_is_seller: true)
    
    request_shape    = create_shape(@community.id, "Request", request_process.id)
    sell_shape       = create_shape(@community.id, "Sell",    offer_process.id)
    
    @request_listing = FactoryGirl.create(
    :listing,
    :transaction_process_id => request_shape[:transaction_process_id],
    :listing_shape_id => request_shape[:id],
    :shape_name_tr_key => request_shape[:name_tr_key],
    :action_button_tr_key => request_shape[:action_button_tr_key],
    :title => "request",
    :description => "I have a request",
    :created_at => 3.days.ago,
    :sort_date => 3.days.ago,
    :author => @person1,
    :privacy => "public"
    )
    @request_listing.communities = [@community]
    
    @offer_listing = FactoryGirl.create(
    :listing,
    :title => "offer",
    :author => @person1,
    :created_at => 2.days.ago,
    :sort_date => 2.days.ago,
    :description => "I have an offer",
    :transaction_process_id => sell_shape[:transaction_process_id],
    :listing_shape_id => sell_shape[:id],
    :shape_name_tr_key => sell_shape[:name_tr_key],
    :action_button_tr_key => sell_shape[:action_button_tr_key],
    :privacy => "public"
    )
    @offer_listing.communities = [@community]
    
    @request_transaction = FactoryGirl.create(
    :transaction,
    :community => @community,
    :listing => @request_listing,
    :starter => @person2,
    )
    
    @offer_transaction = FactoryGirl.create(
    :transaction,
    :community => @community,
    :listing => @offer_listing,
    :starter => @person2,
    )
  end
  
  describe "@request_transaction" do
    it "has author as buyer" do
      @request_transaction.buyer.should == @person1
    end
    
    it "has starter as seller" do
      @request_transaction.seller.should == @person2
    end
  end
  
  describe "@offer_transaction" do
    it "has author as seller" do
      @offer_transaction.seller.should == @person1
    end
    
    it "has starter as buyer" do
      @offer_transaction.buyer.should == @person2
    end
  end
end