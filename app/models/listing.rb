require 'rubygems'
require 'nntp'
require 'rchardet'

class Listing < ActiveRecord::Base

  after_save :write_image_to_file

  after_destroy :delete_image_file

  has_many :conversations

  has_many :comments, :class_name => "ListingComment", :dependent => :destroy 

  belongs_to :author, :class_name => "Person", :foreign_key => "author_id" 

  has_many :person_read_listings, :dependent => :destroy 
  has_many :readers, :through => :person_read_listings, :source => :person

  has_many :person_interesting_listings, :dependent => :destroy 
  has_many :interested_people, :through => :person_interesting_listings, :source => :person

  has_many :kassi_events, :as => :eventable

  has_and_belongs_to_many :groups

  serialize :language, Array

  attr_accessor :language_fi, :language_en, :language_swe, :newsgroup

  acts_as_ferret :fields => {
    :title => {},
    :content => {},
    :id_sort => {:index => :untokenized}
  }

  #Options for status
  VALID_STATUS = ["open", "in_progress", "closed"]

  # Allowed language codes
  VALID_LANGUAGES = ["fi", "swe", "en"]

  # Possible visibility types
  POSSIBLE_VISIBILITIES = ["everybody", "kassi_users", "friends", "contacts", "groups", "f_c", "f_g", "c_g", "f_c_g", "none"]

  # Main categories.
  MAIN_CATEGORIES = ['marketplace', "borrow_items", "lost_property", "rides", "groups", "favors", "others"]
  
  # Newsgroups corresponding to categories
  # 
  # Default groups can be created by adding :default => "name_of_group" 
  NEWSGROUPS = {
    "sell" => { :groups => ["tori.myydaan", "tori.atk.myydaan", "tori.opinnot.myydaan", "tori.liput"] },
    "buy" => { :groups => ["tori.ostetaan", "tori.atk.ostetaan", "tori.opinnot.ostetaan", "tori.liput"] },
    "give" => { :groups => ["tori.myydaan", "tori.atk.myydaan", "tori.opinnot.myydaan", "tori.liput", "tori.sekalaista"] },
    "lost" => { :groups => ["tori.kadonnut"] },
    "rides" => { :groups => ["tori.kyydit"] },
    "others" => { :groups => ["tori.sekalaista"] }
  }

  # Gets subcategories for a category.
  def self.get_sub_categories(main_category)
    case main_category
    when "marketplace"
      ['sell', 'buy', 'give']
    when "lost_property"
      ['lost', 'found']  
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
  THUMB_SIZE = '"100x100>"'

  # Image directories
  if ENV["RAILS_ENV"] == "test"
    URL_STUB = DIRECTORY = "tmp/test_images"
  else
    URL_STUB = "/images/listing_images"
    DIRECTORY = File.join("public", "images", "listing_images")
  end

  validates_presence_of :author_id, :category, :content, :good_thru, :status, :language

  validates_inclusion_of :status, :in => VALID_STATUS
  validates_inclusion_of :visibility, :in => POSSIBLE_VISIBILITIES
  validates_inclusion_of :category, :in => get_valid_categories
  validates_inclusion_of :good_thru, :allow_nil => true, 
  :in => DateTime.now..DateTime.now + 1.year, :message => "must not be more than one year"

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
      elsif @file_data.size > 5.megabyte
        errors.add(:image_file, "can't be bigger than 5 megabytes")
        return false    
      end
    end
    return true
  end

  # Overrides the to_param method to implement clean URLs
  def to_param
    "#{id}_#{title.gsub(/\W/, '_').downcase}"
  end

  # Puts image file data in an instance variable.
  def image_file=(file_data)
    @file_data = file_data
  end

  # Returns image filename.
  def filename
    File.join(DIRECTORY, self.id.to_s + ".png")
  end

  def thumb_filename
    File.join(DIRECTORY, self.id.to_s + "_thumb.png")
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
      thumb = system("#{'convert'} '#{source}' -resize #{THUMB_SIZE} '#{thumb_filename}'")
      # Delete temp file.
      File.delete(source) if File.exists?(source)
      # Conversion must succeed, else it's an error.
      unless img and thumb
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

  def open?
    if status.eql?("closed") || good_thru < Date.today
      return false
    else
      return true
    end    
  end

  # Save group visibility data to db
  def save_group_visibilities(group_ids)
    groups.clear
    if group_ids
      selected_groups = Group.find(group_ids)
      selected_groups.each do |group|
        groups << group
      end
    end
  end

  # Post the contents of the listing to a news.tky.fi group 
  def post_to_newsgroups(url)
    return if !newsgroup || newsgroup.eql?("do_not_post")
    date = DateTime.now().strftime(fmt='%a, %d %b %Y %T %z')

# Tämä on varsinainen viestistring

#     msgstr = <<END_OF_MESSAGE
# From: #{author.name} <#{author.given_name}.#{author.family_name}@not.real.invalid>
# Sender: Kassi
# Newsgroups: #{newsgroup}
# Subject: #{title}
# Date: #{date}
# 
# #{content}
# 
# ***
# 
# This message was sent using Kassi. To reply to this message, go to #{url}
# 
# END_OF_MESSAGE



# Tätä viestistringiä voi käyttää testipostailuihin, niin ei turhaan mene Kassin maine lokaan. :)

#     test_msgstr = <<END_OF_MESSAGE
# From: testi@not.real.invalid>
# Newsgroups: otax.test
# Subject: #{title}
# Date: #{date}
# 
# #{content}
# 
# ***
# 
# END_OF_MESSAGE

    
    # Testiprinttailuja
    
    # logger.info "Message: " + test_msgstr.gsub(/ä/, 'a').gsub(/ö/, 'o')
    # cd = CharDet.detect(test_msgstr)
    # logger.info "Encoding: " + cd['encoding']
    # 
    # logger.info Iconv.new("ISO-8859-1",cd['encoding']).iconv(test_msgstr)
    # 
    # logger.info "Converted:" + Iconv.new("ISO-8859-1",cd['encoding']).iconv(test_msgstr)
 
    
    # Tällä postataan viesti nyysseihin
    
    # if ENV["RAILS_ENV"] == "production"
      # Net::NNTP.start('news.tky.fi', 119) do |nntp|
      #   nntp.post test_msgstr
      #   nntp.post Iconv.new("ISO-8859-1",cd['encoding']).iconv(test_msgstr)
      # end
    # end  
  end

end
