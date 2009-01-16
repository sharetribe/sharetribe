class ListingComment < ActiveRecord::Base
  
  belongs_to :author, :class_name => "Person"
  belongs_to :listing
  
  #named_scope :active_within_2_weeks, :joins => :order, lambda { { :conditions => ["orders.created_at > ?", 2.weeks.ago] } }
  #named_scope :comments_to_own_listings, :joins => :listing, :conditions => ["listings.author_id = 'cNVr_AJ7Kr3BN6ab9B7ckF'"]
  #named_scope :comments_to_own_listings, :joins => :listing, lambda { |id| { :conditions => ["listings.author_id LIKE ?", id] } }
  #named_scope :comments_to_own_listings, :joins => :listing, lambda { { :conditions => ["listings.created_at > ?", 2.weeks.ago] } }
  
  #Client.count(:conditions => "clients.first_name = 'Ryan' AND orders.status = 'received'", :include => "orders")
  
  
  validates_presence_of :author_id, :listing_id, :content
  validates_numericality_of :listing_id, :only_integer => true
  
end
