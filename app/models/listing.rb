# encoding: utf-8
# == Schema Information
#
# Table name: listings
#
#  id                       :integer          not null, primary key
#  author_id                :string(255)
#  category_old             :string(255)
#  title                    :string(255)
#  times_viewed             :integer          default(0)
#  language                 :string(255)
#  created_at               :datetime
#  updates_email_at         :datetime
#  updated_at               :datetime
#  last_modified            :datetime
#  sort_date                :datetime
#  visibility               :string(255)      default("this_community")
#  listing_type_old         :string(255)
#  description              :text
#  origin                   :string(255)
#  destination              :string(255)
#  valid_until              :datetime
#  delta                    :boolean          default(TRUE), not null
#  open                     :boolean          default(TRUE)
#  share_type_old           :string(255)
#  privacy                  :string(255)      default("private")
#  comments_count           :integer          default(0)
#  subcategory_old          :string(255)
#  old_category_id          :integer
#  category_id              :integer
#  share_type_id            :integer
#  transaction_type_id      :integer
#  organization_id          :integer
#  price_cents              :integer
#  currency                 :string(255)
#  quantity                 :string(255)
#  deleted                  :boolean          default(FALSE)
#  require_shipping_address :boolean          default(FALSE)
#  pickup_enabled           :boolean          default(FALSE)
#  shipping_price_cents     :integer
#
# Indexes
#
#  index_listings_on_category_id          (old_category_id)
#  index_listings_on_listing_type         (listing_type_old)
#  index_listings_on_open                 (open)
#  index_listings_on_share_type_id        (share_type_id)
#  index_listings_on_transaction_type_id  (transaction_type_id)
#  index_listings_on_visibility           (visibility)
#

class Listing < ActiveRecord::Base

  # http://pat.github.io/thinking-sphinx/advanced_config.html
  SPHINX_MAX_MATCHES = 1000

  include ApplicationHelper
  include ActionView::Helpers::TranslationHelper
  include Rails.application.routes.url_helpers

  belongs_to :author, :class_name => "Person", :foreign_key => "author_id"

  has_many :listing_images, :dependent => :destroy

  has_many :conversations
  has_many :comments, :dependent => :destroy
  has_many :custom_field_values, :dependent => :destroy
  has_many :custom_dropdown_field_values, :class_name => "DropdownFieldValue"
  has_many :custom_checkbox_field_values, :class_name => "CheckboxFieldValue"

  has_one :location, :dependent => :destroy
  has_one :origin_loc, :class_name => "Location", :conditions => ['location_type = ?', 'origin_loc'], :dependent => :destroy
  has_one :destination_loc, :class_name => "Location", :conditions => ['location_type = ?', 'destination_loc'], :dependent => :destroy
  accepts_nested_attributes_for :origin_loc, :destination_loc

  has_and_belongs_to_many :communities
  has_and_belongs_to_many :followers, :class_name => "Person", :join_table => "listing_followers"

  belongs_to :category
  belongs_to :transaction_type

  delegate :direction, to: :transaction_type
  delegate :status_after_reply, to: :transaction_type

  monetize :price_cents, :allow_nil => true, with_model_currency: :currency
  monetize :shipping_price_cents, allow_nil: true, with_model_currency: :currency

  attr_accessor :current_community_id

  scope :public, :conditions  => "privacy = 'public'"
  scope :private, :conditions  => "privacy = 'private'"

  # Create an "empty" relationship. This is needed in search when we want to stop the search chain (NumericFields)
  # and just return empty result.
  #
  # When moving to Rails 4.0, remove this and use Model.none
  # http://stackoverflow.com/questions/4877931/how-to-return-an-empty-activerecord-relation
  scope :none, where('1 = 0')

  VALID_VISIBILITIES = ["this_community", "all_communities"]
  VALID_PRIVACY_OPTIONS = ["private", "public"]

  before_validation :set_valid_until_time
  before_save :set_community_visibilities

  validates_presence_of :author_id
  validates_length_of :title, :in => 2..60, :allow_nil => false

  before_create :set_sort_date_to_now
  def set_sort_date_to_now
    self.sort_date ||= Time.now
  end

  before_create :set_updates_email_at_to_now
  def set_updates_email_at_to_now
    self.updates_email_at ||= Time.now
  end

  before_validation do
    # Normalize browser line-breaks.
    # Reason: Some browsers send line-break as \r\n which counts for 2 characters making the
    # 5000 character max length validation to fail.
    # This could be more general helper function, if this is needed in other textareas.
    self.description = description.gsub("\r\n","\n") if self.description
  end
  validates_length_of :description, :maximum => 5000, :allow_nil => true
  validates_inclusion_of :visibility, :in => VALID_VISIBILITIES
  validates_presence_of :category
  validates_presence_of :transaction_type
  validates_inclusion_of :valid_until, :allow_nil => :true, :in => DateTime.now..DateTime.now + 7.months
  validates_numericality_of :price_cents, :only_integer => true, :greater_than_or_equal_to => 0, :message => "price must be numeric", :allow_nil => true

  def set_community_visibilities
    if current_community_id
      communities.clear
      if visibility.eql?("this_community")
        communities << Community.find(current_community_id)
      else
        author.communities.each { |c| communities << c }
      end
    end
  end

  # Filter out listings that current user cannot see
  def self.visible_to(current_user, current_community, ids=nil)
    id_list = ids ? ids : current_community.listings.pluck(:id)
    if current_user && current_user.member_of?(current_community)
      where("listings.id IN (?)", id_list)
    else
      where("listings.privacy = 'public' AND listings.id IN (?)", id_list)
    end
  end

  def self.currently_open(status="open")
    status = "open" if status.blank?
    case status
    when "all"
      where([])
    when "open"
      where(["open = '1' AND (valid_until IS NULL OR valid_until > ?)", DateTime.now])
    when "closed"
      where(["open = '0' OR (valid_until IS NOT NULL AND valid_until < ?)", DateTime.now])
    end
  end

  def visible_to?(current_user, current_community)
    ListingVisibilityGuard.new(self, current_community, current_user).visible?
  end

  def public?
    self.privacy.eql?("public")
  end

  # Get only listings that are restricted only to the members of the current
  # community (or to many communities including current)
  def self.private_to_community(community)
    where("
      listings.privacy = 'private'
      AND listings.id IN (SELECT listing_id FROM communities_listings WHERE community_id = '#{community.id}')
    ")
  end

  # sets the time to midnight
  def set_valid_until_time
    if valid_until
      self.valid_until = valid_until.utc + (23-valid_until.hour).hours + (59-valid_until.min).minutes + (59-valid_until.sec).seconds
    end
  end

  # Overrides the to_param method to implement clean URLs
  def to_param
    "#{id}-#{title.to_url}"
  end

  def self.find_with(params, current_user=nil, current_community=nil, per_page=100, page=1)
    params ||= {}  # Set params to empty hash if it's nil
    joined_tables = []

    params[:include] ||= [:listing_images, :category, :transaction_type]

    params.reject!{ |key,value| (value == "all" || value == ["all"]) && key != "status"} # all means the fliter doesn't need to be included (except with "status")

    # If no Share Type specified, use listing_type param if that is specified.
    # :listing_type and :share_type are deprecated and they should not be used.
    # However, API may use them still
    params[:share_type] ||= params[:listing_type]
    params.delete(:listing_type) # In any case listing_type is not a search param used any more

    params[:search] ||= params[:q] # Read search query also from q param

    if params[:category].present?
      category = Category.find_by_id(params[:category])
      if category
        params[:categories] = {:id => category.with_all_children.collect(&:id)}
        joined_tables << :category
      else
        # ignore the category attribute if it's not found
      end
    end

    # :share_type is deprecated, but we need to support it for the ATOM API
    # Share type is overriden by transaction_type if it is present
    if params[:share_type].present?
      direction = params[:share_type]
      params[:transaction_types] = {:id => current_community.transaction_types.select { |transaction_type| transaction_type.direction == direction }.collect(&:id) }
    end

    if params[:transaction_type].present?
      # Sphinx expects integer
      params[:transaction_types] = {:id => params[:transaction_type].to_i}
    end

    if params[:transaction_type].present? || params[:share_type].present?
      joined_tables << :transaction_type
    end

    # Two ways of finding, with or without sphinx
    if search_with_sphinx?(params)

      # sort by time by default
      params[:sort] ||= 'sort_date DESC'

      with = {}
      # Currently forced to only open at listing_index.rb
      # if params[:status] == "open" || params[:status].nil?
      #   with[:open] = true
      # elsif params[:status] == "closed"
      #   with[:open] = false
      # end

      unless current_user && current_user.communities.include?(current_community)
        with[:visible_to_everybody] = true
      end
      with[:community_ids] = current_community.id

      with[:category_id] = params[:categories][:id] if params[:categories].present?
      with[:transaction_type_id] = params[:transaction_types][:id] if params[:transaction_types].present?
      with[:listing_id] = params[:listing_id] if params[:listing_id].present?
      with[:price_cents] = params[:price_cents] if params[:price_cents].present?

      params[:custom_dropdown_field_options] ||= [] # use emtpy table rather than nil to avoid confused sphinx

      with_all = {:custom_dropdown_field_options => params[:custom_dropdown_field_options]}

      params[:custom_checkbox_field_options] ||= [] # use emtpy table rather than nil to avoid confused sphinx

      with_all[:custom_checkbox_field_options] = params[:custom_checkbox_field_options]

      params[:search] ||= "" #at this point use empty string as Riddle::Query.escape fails with nil

      page = page ? page.to_i : 1

      listings = if search_out_of_bounds?(per_page, page)
        Listing.none.paginate(:per_page => per_page, :page => page)
      else
        Listing.search(
          Riddle::Query.escape(params[:search]),
          :include => params[:include],
          :page => page,
          :per_page => per_page,
          :star => true,
          :with => with,
          :with_all => with_all,
          :order => params[:sort]
        )
      end

    else # No search query or filters used, no sphinx needed
      query = {}
      query[:categories] = params[:categories] if params[:categories]
      # FIX THIS query[:transaction_types] = params[:transaction_types] if params[:transaction_types]
      query[:author_id] = params[:person_id] if params[:person_id]    # this is not yet used with search
      query[:id] = params[:listing_id] if params[:listing_id].present?
      listings = joins(joined_tables).where(query).currently_open(params[:status]).visible_to(current_user, current_community).includes(params[:include]).order("listings.sort_date DESC").paginate(:per_page => per_page, :page => page)
    end
    return listings
  end

  def self.search_out_of_bounds?(per_page, page)
    pages = (SPHINX_MAX_MATCHES.to_f / per_page.to_f)
    page > pages.ceil
  end

  def self.search_with_sphinx?(params)
    params[:search].present? || params[:transaction_types].present? || params[:category].present? || params[:custom_dropdown_field_options].present?  || params[:custom_checkbox_field_options].present? || params[:price_cents].present?
  end

  def self.find_by_category_and_subcategory(category)
    Listing.where(:category_id => category.own_and_subcategory_ids)
  end

  # Listing type is not anymore stored separately, so we serach it by share_type top level parent
  # And return a string here, as that's what expected in most existing cases (e.g. translation strings)
  def listing_type
    return transaction_type.direction
  end

  # Returns true if listing exists and valid_until is set
  def temporary?
    !new_record? && valid_until
  end

  def update_fields(params)
    update_attribute(:valid_until, nil) unless params[:valid_until]
    update_attributes(params)
  end

  def closed?
    !open? || (valid_until && valid_until < DateTime.now)
  end

  def self.opposite_type(type)
    raise "Listing.opposite_type is deprecated"
    type.eql?("offer") ? "request" : "offer"
  end

  # Returns true if the given person is offerer and false if requester
  def offerer?(person)
    (transaction_type.is_offer? && author.eql?(person)) || (transaction_type.is_request? && !author.eql?(person))
  end

  # Returns true if the given person is requester and false if offerer
  def requester?(person)
    (transaction_type.is_request? && author.eql?(person)) || (transaction_type.is_offer? && !author.eql?(person))
  end

  # If listing is an offer, a discussion about the listing
  # should be request, and vice versa
  def discussion_type
    transaction_type.is_request? ? "offer" : "request"
  end

  # This is used to provide clean JSON-strings for map view queries
  def as_json(options = {})

    # This is currently optimized for the needs of the map, so if extending, make a separate JSON mode, and keep map data at minimum
    hash = {
      :listing_type => self.transaction_type.direction,
      :category => self.category.id,
      :id => self.id,
      :icon => icon_class(icon_name)
    }
    if self.origin_loc
      hash.merge!({:latitude => self.origin_loc.latitude,
                  :longitude => self.origin_loc.longitude})
    end
    return hash
  end

  # Send notifications to the users following this listing
  # when the listing is updated (update=true) or a
  # new comment to the listing is created.
  def notify_followers(community, current_user, update)
    followers.each do |follower|
      unless follower.id == current_user.id
        if update
          PersonMailer.new_update_to_followed_listing_notification(self, follower, community).deliver
        else
          PersonMailer.new_comment_to_followed_listing_notification(comments.last, follower, community).deliver
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
    custom_field_values.find { |value| value.custom_field_id == custom_field.id }
  end

  def payment_required_at?(community)
    transaction_type.price_field? && community.payments_in_use?
  end
end
