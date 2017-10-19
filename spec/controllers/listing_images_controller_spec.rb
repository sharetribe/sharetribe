# encoding: utf-8

# == Schema Information
#
# Table name: listing_images
#
#  id                 :integer          not null, primary key
#  listing_id         :integer
#  created_at         :datetime
#  updated_at         :datetime
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  image_processing   :boolean
#  image_downloaded   :boolean          default(FALSE)
#  error              :string(255)
#  width              :integer
#  height             :integer
#  author_id          :string(255)
#  position           :integer          default(0)
#
# Indexes
#
#  index_listing_images_on_listing_id  (listing_id)
#


#Tests LisingControllers reorder feature

require 'spec_helper'

describe ListingImagesController, type: :controller do
  render_views

  before(:each) do
    Rails.cache.clear
  end

  def create_shape(community_id, type, process_id, translations = [], categories = [])
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

    ListingShape.create_with_opts(community: Community.find(community_id), opts: opts)
  end

  before(:each) do
    Listing.all.collect(&:destroy) # for some reason there's a listing before starting. Destroy to be clear.

    @c1 = FactoryGirl.create(:community, :settings => {"locales" => ["en", "fi"]})
    @c1.community_customizations << FactoryGirl.create(:community_customization, :locale => "fi")

    @p1 = FactoryGirl.create(:person)
    @p1.accepted_community = @c1

    c1_request_process = TransactionProcess.create(community_id: @c1.id, process: :none, author_is_seller: false)
    request_shape    = create_shape(@c1.id, "Request", c1_request_process.id)

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
      :community_id => @c1.id
    )

    @request.host = "#{@c1.ident}.lvh.me"
    @request.env[:current_marketplace] = @c1
  end

  def stubbed_upload(filename, content_type)
    fixture_file_upload("#{Rails.root}/spec/fixtures/#{filename}", content_type, :binary)
  end

  describe "POST #add_from_file" do
    before do
      sign_in_for_spec(@p1)
    end

    it "sets image position on upload" do
      5.times{|i| post :add_from_file, params: { listing_id: @l1.id, listing_image: { image: stubbed_upload('Bison_skull_pile.png', 'image/png') } } }

      expect(@l1.listing_images.size).to eq(5)
      expect(@l1.listing_images.map(&:position)).to eq([1,2,3,4,5])
    end
  end

  describe "PUT #reorder" do
    before do
      sign_in_for_spec(@p1)
    end

    it "changes order of images" do
      5.times{|i| post :add_from_file, params: { listing_id: @l1.id, listing_image: { image: stubbed_upload('Bison_skull_pile.png', 'image/png') } } }
      orig_ids = @l1.listing_images.map(&:id)

      mixed_ids = nil
      loop do # shuffle for sure
        mixed_ids = orig_ids.shuffle
        break if mixed_ids != orig_ids
      end
      expect(mixed_ids).not_to eq(orig_ids)

      put :reorder, params: { listing_id: @l1.id, ordered_ids: mixed_ids.join(",") }
      expect(response.body).to eq("OK")

      @l1.reload
      current_ids = @l1.listing_images.map(&:id)
      expect(current_ids).to eq(mixed_ids)
    end
  end
end
