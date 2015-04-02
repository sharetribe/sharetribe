class Admin::ListingShapesController < ApplicationController
  before_filter :ensure_is_admin

  # TODO before_filter :feature_flag

  LISTING_SHAPES_NAVI_LINK = "listing_shapes"

  # :id=>127,
  # :transaction_type_id=>65,
  # :community_id=>10,
  # :price_enabled=>false,
  # :name_tr_key=>"transaction_type_translation.name.65",
  # :action_button_tr_key=>
  # "transaction_type_translation.action_button_label.65",
  # :transaction_process_id=>17,
  # :translations=>nil,
  # :units=>[],
  # :shipping_enabled=>false,
  # :price_quantity_placeholder=>nil

  ListingShapeForm = FormUtils.define_form(
    "ListingShapeForm",
    :name,
    :action_button_label,
    :shipping_enabled)

  def index
    render("index",
           locals: {
             selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
             listing_shapes: all_shapes(@current_community.id)})
  end

  def edit
    shape = get_shape(@current_community.id, params[:id])
    return redirect_to error_not_found_path if shape.nil?

    render("edit",
           locals: {
             selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
             shape: shape,
             shape_form: to_form(shape, @current_community.id, available_locales().map(&:second)),
             locale_name_mapping: available_locales().map { |name, l| [l, name]}.to_h })
  end

  def update
    binding.pry
  end


  private

  def all_shapes(community_id)
    listing_api.shapes.get(community_id: community_id)
      .maybe()
      .or_else([])
  end

  def get_shape(community_id, listing_shape_id)
    listing_api.shapes.get(community_id: community_id, listing_shape_id: listing_shape_id)
      .maybe()
      .or_else(nil)
  end

  def to_form(shape, community_id, locales)
    trs = TranslationServiceHelper.to_key_locale_hash(
      get_translations(shape, community_id, locales))

    ListingShapeForm.new(name: trs[shape[:name_tr_key]], action_button_label: trs[shape[:action_button_tr_key]], shipping_enabled: shape[:shipping_enabled])
  end

  def get_translations(shape, community_id, locales)
    translations_api.translations.get(
      community_id,
      translation_keys: [shape[:name_tr_key], shape[:action_button_tr_key]],
      locales: locales)
      .maybe()
      .or_else([])
  end

  def listing_api
    ListingService::API::Api
  end

  def translations_api
    TranslationService::API::Api
  end
end
