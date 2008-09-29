class Listing < ActiveRecord::Base

  after_save :write_image_to_file
  
  after_destroy :delete_image_file
  
  has_many :person_conversations
  has_many :conversations, :through => :person_conversations, :source => :conversation
  
  has_many :comments, :class_name => "ListingComment"
  
  belongs_to :author, :class_name => "Person"
  
  has_many :person_read_listings
  has_many :readers, :through => :person_read_listings, :source => :person
  
  has_many :person_interesting_listings
  has_many :interested_people, :through => :person_interesting_listings, :source => :person
  
  serialize :language, Array
  
  attr_accessor :language_fi, :language_en, :language_swe
  
  acts_as_ferret :fields => {
    :title => {},
    :content => {},
    :id_sort => {:index => :untokenized}
  }
  
  #Options for status
  VALID_STATUS =  ["open", "in_progress", "closed"]
  
  # Allowed language codes
  VALID_LANGUAGES = ["fi", "swe", "en-US"]
  
  # Main categories.
  MAIN_CATEGORIES = ['marketplace', "borrow_items", "lost_property", "rides", "groups", "favors", "others"]

  # Gets subcategories for a category.
  def self.get_sub_categories(main_category)
    case main_category
    when "marketplace"
      ['sell', 'buy', 'give']
    else
      nil 
    end  
  end
  
  # Gets all categories that are valid for a single listing.
  # Categories that have subcategories are not valid.
  def self.get_valid_categories
    valid_categories = []
    MAIN_CATEGORIES.each do |category|
      if get_sub_categories(category)
        get_sub_categories(category).each do |subcategory|
          valid_categories << subcategory
        end  
      else
        valid_categories << category  
      end
    end
    return valid_categories
  end

  # Image sizes
  IMG_SIZE = '"300x240>"'
  
  # Image directories
  if ENV["RAILS_ENV"] == "test"
    URL_STUB = DIRECTORY = "tmp/test_images"
  else
    URL_STUB = "/images/listing_images"
    DIRECTORY = File.join("public", "images", "listing_images")
  end
  
  validates_presence_of :author_id, :category, :title, :content, :good_thru, :status, :language

  validates_inclusion_of :status, :in => VALID_STATUS
  validates_inclusion_of :category, :in => get_valid_categories
  validates_inclusion_of :good_thru, :allow_nil => true, 
                         :in => DateTime.now..DateTime.now + 1.year
  
  validates_length_of :title, :within => 2..50
  validates_length_of :value_other, :allow_nil => true, :allow_blank => true, :maximum => 50
  
  validates_numericality_of :times_viewed, :value_cc, :only_integer => true, :allow_nil => true
  
  validate :given_language_is_one_of_valid_languages, :file_data_is_valid

  # Makes sure that the all the languages given are valid.
  def given_language_is_one_of_valid_languages
    unless language.nil?
      language.each do |test_language|
        errors.add(:language, "should be one of the valid ones") if !VALID_LANGUAGES.include?(test_language)
      end
    end  
  end
  
  # Validates image if image data is given. Listing is also valid 
  # without image, so no file data equals valid file data.
  def file_data_is_valid
    if @file_data
      if @file_data.size.zero?
        return true
      elsif @file_data.content_type !~ /^image/
        errors.add(:image_file, "is not a recognized format")
        return false
      elsif @file_data.size > 1.megabyte
        errors.add(:image_file, "can't be bigger than 1 megabyte")
        return false    
      end
    end
    return true
  end
  
  # Overrides the to_param method to implement clean URLs
  def to_param
    "#{id}-#{title.gsub(/\W/, '-').downcase}"
  end
  
  # Puts image file data in an instance variable.
  def image_file=(file_data)
    @file_data = file_data
  end
  
  # Returns image filename.
  def filename
    File.join(DIRECTORY, self.id.to_s + ".png")
  end
  
  # Converts image to right size and writes it to a PNG file.
  # Filename is [LISTING_ID].png
  def write_image_to_file
    if (@file_data && !@file_data.size.zero?)
      Dir.mkdir(DIRECTORY) unless File.directory?(DIRECTORY) 
      # Prepare the filenames for the conversion.
      source = File.join("tmp",self.id.to_s)
      # Ensure that small and large images both work by writing to a normal file. 
      # (Small files show up as StringIO, larger ones as Tempfiles.)
      File.open(source, "wb") { |f| f.write(@file_data.read) }
      # Convert the files.
      img = system("#{'convert'} '#{source}' -resize #{IMG_SIZE} '#{filename}'")
      # Delete temp file.
      File.delete(source) if File.exists?(source)
      # Conversion must succeed, else it's an error.
      unless img
        errors.add_to_base("File upload failed.  Try a different image?")
        return false
      end
      return true
    end
  end
  
  # Deletes image file if listing is destroyed.
  def delete_image_file
    File.delete(filename) if File.exists?(filename)
  end

  def id_sort
    id
  end  

end
