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

class Listing < ApplicationRecord

  include ApplicationHelper
  include ActionView::Helpers::TranslationHelper
  include Rails.application.routes.url_helpers
  include ManageAvailabilityPerHour

  belongs_to :community
  belongs_to :author, :class_name => "Person", :foreign_key => "author_id", :inverse_of => :listings

  has_many :listing_images, -> { where("error IS NULL").order("position") }, :dependent => :destroy, :inverse_of => :listing

  has_many :conversations, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :custom_field_values, :dependent => :destroy
  has_many :custom_dropdown_field_values, :class_name => "DropdownFieldValue", :dependent => :destroy
  has_many :custom_checkbox_field_values, :class_name => "CheckboxFieldValue", :dependent => :destroy

  has_one :location, :dependent => :destroy
  has_one :origin_loc, -> { where('location_type = ?', 'origin_loc') }, :class_name => "Location", :dependent => :destroy, :inverse_of => :listing
  has_one :destination_loc, -> { where('location_type = ?', 'destination_loc') }, :class_name => "Location", :dependent => :destroy, :inverse_of => :listing
  accepts_nested_attributes_for :origin_loc, :destination_loc

  has_and_belongs_to_many :followers, :class_name => "Person", :join_table => "listing_followers"

  belongs_to :category
  has_many :working_time_slots, ->{ ordered }, dependent: :destroy, inverse_of: :listing
  accepts_nested_attributes_for :working_time_slots, reject_if: :all_blank, allow_destroy: true

  belongs_to :listing_shape

  has_many :tx, class_name: 'Transaction', :dependent => :destroy
  has_many :bookings, through: :tx
  has_many :bookings_per_hour, ->{ per_hour_blocked }, through: :tx, source: :booking

  monetize :price_cents, :allow_nil => true, with_model_currency: :currency
  monetize :shipping_price_cents, allow_nil: true, with_model_currency: :currency
  monetize :shipping_price_additional_cents, allow_nil: true, with_model_currency: :currency

  before_validation :set_valid_until_time

  validates_presence_of :author_id
  validates_length_of :title, :in => 2..65, :allow_nil => false

  scope :exist, -> { where(deleted: false) }

  scope :search_title_author_category, ->(pattern) do
    joins(:author)
      .joins(:category => :translations)
      .where("listings.title like :pattern
        OR (category_translations.locale = :locale AND category_translations.name like :pattern)
        OR (people.given_name like :pattern OR people.family_name like :pattern OR people.display_name like :pattern)",
        locale: I18n.locale,
        pattern: "%#{pattern}%")
  end

  HOMEPAGE_INDEX = "listings_homepage_query"
  # Use this scope before any query part to give DB server an index hint
  scope :use_index, ->(index) { from("#{self.table_name} USE INDEX (#{index})") }
  scope :use_homepage_index, -> { use_index(HOMEPAGE_INDEX) }

  scope :status_open, ->   { where(open: true) }
  scope :status_closed, -> { where(open: false) }
  scope :status_expired, -> { where('valid_until < ?', DateTime.now) }
  scope :status_active, -> { where('valid_until > ? or valid_until is null', DateTime.now) }
  scope :status_open_active, -> { status_open.status_active.approved }
  scope :currently_open, -> { exist.status_open.approved.where(["valid_until IS NULL OR valid_until > ?", DateTime.now]) }

  scope :for_export, -> { includes(:listing_images).exist.order('created_at DESC') }

  APPROVALS = {
    APPROVED = 'approved'.freeze => 'approved'.freeze,
    APPROVAL_PENDING = 'approval_pending'.freeze => 'pending_admin_approval'.freeze,
    APPROVAL_REJECTED = 'approval_rejected'.freeze => 'rejected'.freeze
  }
  enum state: APPROVALS

  before_create :set_sort_date_to_now
  def set_sort_date_to_now
    self.sort_date ||= Time.now
  end

  before_create :set_updates_email_at_to_now
  def set_updates_email_at_to_now
    self.updates_email_at ||= Time.now
  end

  def uuid_object
    if self[:uuid].nil?
      nil
    else
      UUIDUtils.parse_raw(self[:uuid])
    end
  end

  def uuid_object=(uuid)
    self.uuid = UUIDUtils.raw(uuid)
  end

  before_create :add_uuid
  def add_uuid
    self.uuid ||= UUIDUtils.create_raw
  end

  before_validation do
    # Normalize browser line-breaks.
    # Reason: Some browsers send line-break as \r\n which counts for 2 characters making the
    # 5000 character max length validation to fail.
    # This could be more general helper function, if this is needed in other textareas.
    self.description = description.gsub("\r\n","\n") if self.description
  end
  validates_length_of :description, :maximum => 5000, :allow_nil => true
  validates_presence_of :category
  validates_inclusion_of :valid_until, :allow_nil => true, :in => proc{ DateTime.now..DateTime.now + 7.months }
  validates_numericality_of :price_cents, :only_integer => true, :greater_than_or_equal_to => 0, :message => "price must be numeric", :allow_nil => true

  # sets the time to midnight
  def set_valid_until_time
    if valid_until
      self.valid_until = valid_until.utc + (23-valid_until.hour).hours + (59-valid_until.min).minutes + (59-valid_until.sec).seconds
    end
  end

  # Overrides the to_param method to implement clean URLs
  def to_param
    self.class.to_param(id, title)
  end

  def self.to_param(id, title)
    "#{id}-#{title.to_url}"
  end

  def self.find_by_category_and_subcategory(category)
    Listing.where(:category_id => category.own_and_subcategory_ids)
  end

  # Returns true if listing exists and valid_until is set
  def temporary?
    !new_record? && valid_until
  end

  def update_fields(params)
    update_attribute(:valid_until, nil) unless params[:valid_until]
    update(params)
  end

  def closed?
    !open? || (valid_until && valid_until < DateTime.now)
  end

  # Send notifications to the users following this listing
  # when the listing is updated (update=true) or a
  # new comment to the listing is created.
  def notify_followers(community, current_user, update)
    followers.each do |follower|
      unless follower.id == current_user.id
        if update
          MailCarrier.deliver_now(PersonMailer.new_update_to_followed_listing_notification(self, follower, community))
        else
          MailCarrier.deliver_now(PersonMailer.new_comment_to_followed_listing_notification(comments.last, follower, community))
        end
      end
    end
  end

  def image_by_id(id)
    listing_images.find_by_id(id)
  end

  def prev_and_next_image_ids_by_id(id)
    listing_image_ids = listing_images.collect(&:id)
    ArrayUtils.next_and_prev(listing_image_ids, id);
  end

  def has_image?
    !listing_images.empty?
  end

  def icon_name
    category.icon_name
  end

  # The price symbol based on this listing's price or community default, if no price set
  def price_symbol
    price ? price.symbol : MoneyRails.default_currency.symbol
  end

  def answer_for(custom_field)
    custom_field_values.by_question(custom_field).first
  end

  def unit_type
    Maybe(read_attribute(:unit_type)).to_sym.or_else(nil)
  end

  def init_origin_location(location)
    if location.present?
      build_origin_loc(location.attributes)
    else
      build_origin_loc()
    end
  end

  def ensure_origin_loc
    build_origin_loc unless origin_loc
  end

  def custom_field_value_factory(custom_field_id, answer_value)
    question = CustomField.find(custom_field_id)

    answer = question.with_type do |question_type|
      case question_type
      when :dropdown
        option_id = answer_value.to_i
        answer = DropdownFieldValue.new
        answer.custom_field_option_selections = [CustomFieldOptionSelection.new(:custom_field_value => answer,
                                                                                :custom_field_option_id => option_id,
                                                                                :listing_id => self.id)]
        answer
      when :text
        answer = TextFieldValue.new
        answer.text_value = answer_value
        answer
      when :numeric
        answer = NumericFieldValue.new
        answer.numeric_value = ParamsService.parse_float(answer_value)
        answer
      when :checkbox
        answer = CheckboxFieldValue.new
        answer.custom_field_option_selections = answer_value.map { |value|
          CustomFieldOptionSelection.new(:custom_field_value => answer, :custom_field_option_id => value, :listing_id => self.id)
        }
        answer
      when :date_field
        answer = DateFieldValue.new
        answer.date_value = Time.utc(answer_value["(1i)"].to_i,
                                     answer_value["(2i)"].to_i,
                                     answer_value["(3i)"].to_i)
        answer
      else
        raise ArgumentError.new("Unimplemented custom field answer for question #{question_type}")
      end
    end

    answer.question = question
    answer.listing_id = self.id
    return answer
  end

  # Note! Requires that parent self is already saved to DB. We
  # don't use association to link to self but directly connect to
  # self_id.
  def upsert_field_values!(custom_field_params)
    custom_field_params ||= {}

    # Delete all existing
    custom_field_value_ids = self.custom_field_values.map(&:id)
    CustomFieldOptionSelection.where(custom_field_value_id: custom_field_value_ids).delete_all
    CustomFieldValue.where(id: custom_field_value_ids).delete_all

    field_values = custom_field_params.map do |custom_field_id, answer_value|
      custom_field_value_factory(custom_field_id, answer_value) unless is_answer_value_blank(answer_value)
    end.compact

    # Insert new custom fields in a single transaction
    CustomFieldValue.transaction do
      field_values.each(&:save!)
    end
  end

  def is_answer_value_blank(value)
    if value.is_a?(Hash)
      value["(3i)"].blank? || value["(2i)"].blank? || value["(1i)"].blank?  # DateFieldValue check
    else
      value.blank?
    end
  end

  def reorder_listing_images(params, user_id)
    listing_image_ids =
      if params[:listing_images]
        params[:listing_images].collect { |h| h[:id] }.select { |id| id.present? }
      else
        logger.error("Listing images array is missing", nil, {params: params})
        []
      end

    ListingImage.where(id: listing_image_ids, author_id: user_id).update_all(listing_id: self.id)

    if params[:listing_ordered_images].present?
      params[:listing_ordered_images].split(",").each_with_index do |image_id, position|
        ListingImage.where(id: image_id, author_id: user_id).update_all(position: position+1)
      end
    end
  end

  def logger
    @logger ||= SharetribeLogger.new(:listing, logger_metadata.keys).tap { |logger|
      logger.add_metadata(logger_metadata)
    }
  end

  def logger_metadata
    { listing_id: id }
  end

  def self.delete_by_author(author_id)
    listings = Listing.where(author_id: author_id)
    listings.update_all(
      # Delete listing info
      description: nil,
      origin: nil,
      open: false,
      deleted: true
    )
    listings.each do |listing|
      listing.location&.destroy
    end
    ids = listings.pluck(:id)
    ListingImage.where(listing_id: ids).destroy_all
  end
end
