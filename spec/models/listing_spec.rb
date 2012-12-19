require 'spec_helper'

describe Listing do
  
  before(:each) do
    @listing = FactoryGirl.build(:listing)
  end  
  
  it "is valid with valid attributes" do
    @listing.should be_valid
  end  
  
  it "is not valid without a title" do
    @listing.title = nil 
    @listing.should_not be_valid
  end
  
  it "is not valid with a too short title" do
    @listing.title = "a" 
    @listing.should_not be_valid
  end
  
  it "is not valid with a too long title" do
    @listing.title = "0" * 101 
    @listing.should_not be_valid
  end
  
  it "is valid without a description" do
    @listing.description = nil 
    @listing.should be_valid
  end
  
  it "is not valid if description is longer than 5000 characters" do
    @listing.description = "0" * 5001
    @listing.should_not be_valid
  end
  
  it "is not valid without an author id" do
    @listing.author_id = nil
    @listing.should_not be_valid
  end
  
  it "is not valid without listing type" do
    @listing.listing_type = nil
    @listing.should_not be_valid
  end
  
  it "is only valid if listing type is one of the valid types" do
    @listing.listing_type = "test"
    @listing.should_not be_valid
    Listing::VALID_TYPES.each do |type|
      @listing.listing_type = type
      valid_with_share_types
    end  
  end
  
  it "is not valid without category" do
    @listing.category = nil
    @listing.should_not be_valid
  end 
  
  it "is only valid if category is one of the valid categories" do
    @listing.category = "test"
    @listing.should_not be_valid
    Listing::VALID_CATEGORIES.reject { |c| c.eql?("rideshare") }.each do |category|
      @listing.category = category
      valid_with_share_types
    end  
  end
  
  it "is only valid if the share type corresponds with the category" do
    @listing.share_type = nil
    @listing.should_not be_valid
    Listing::VALID_CATEGORIES.each { |c| listing_is_valid_with_correct_share_type("offer", c) }
    Listing::VALID_CATEGORIES.each { |c| listing_is_valid_with_correct_share_type("request", c) }
    [
      ["request", "item", "test"],
      ["request", "favor", "borrow"],
      ["request", "rideshare", "sell"],
      ["request", "housing", "test"],
      ["offer", "item", "test"],
      ["offer", "housing", "test"]
    ].each { |array| listing_is_not_valid_with_incorrect_share_type(array[0], array[1], array[2]) }
  end

  it "should not be valid when there is no valid until" do
    @listing.valid_until = nil
    @listing.should_not be_valid
  end
  
  it "should not be valid when valid until date is before current date" do
    @listing.valid_until = DateTime.now - 1.day - 1.minute
    @listing.should_not be_valid
  end

  it "should not be valid when valid until is more than one year after current time" do
    @listing.valid_until = DateTime.now + 1.year + 1.hour
    @listing.should_not be_valid
  end
  
  context "with listing type 'offer'" do
  
    before(:each) do
      @listing.listing_type = "offer"
      @listing.share_type = "lend"
    end
    
    it "should be valid when there is no valid until" do
      @listing.valid_until = nil
      @listing.should be_valid
    end 
  
  end
  
  context "with category 'rideshare'" do
    
    before(:each) do
      @listing.share_type = nil
      @listing.category = "rideshare"
      @listing.origin = "Otaniemi"
      @listing.destination = "Turku"
    end  
    
    it "is valid with valid origin and destination" do
      @listing.should be_valid
    end
    
    it "is not valid without origin" do
      @listing.origin = nil
      @listing.should_not be_valid
    end
    
    it "is not valid without destination" do
      @listing.destination = nil
      @listing.should_not be_valid
    end
    
    it "is not valid with a too short origin" do
      @listing.origin = "a"
      @listing.should_not be_valid
    end
    
    it "is not valid with a too long origin" do
      @listing.origin = "a" * 49
      @listing.should_not be_valid
    end
    
    it "is not valid with a too short destination" do
      @listing.destination = "a"
      @listing.should_not be_valid
    end
    
    it "is not valid with a too long destination" do
      @listing.destination = "a" * 51
      @listing.should_not be_valid
    end
    
    it "is not valid with share type" do
      @listing.share_type = "buy"
      @listing.should_not be_valid
    end  
    
    it "should have a title in the form of [ORIGIN]-[DESTINATION]" do    
      @listing.title = "test"
      @listing.should be_valid
      @listing.title.should == "Otaniemi - Turku"
    end
    
    it "should not be valid when valid until is less than current time" do
      @listing.valid_until = DateTime.now - 1.hour
      @listing.should_not be_valid
    end
    
    it "should be valid when there is no valid until" do
      @listing.listing_type = "offer"
      @listing.valid_until = nil
      @listing.should be_valid
    end
    
    describe "#origin_and_destination_close_enough?" do
      it "should return true, when comparing listings with origin and destination close enough" do
        other_listing = FactoryGirl.build(:listing)
        other_listing.category = "rideshare"
        other_listing.origin = "Otakaari 20"
        other_listing.destination = "Simonkatu 4"
        @listing.destination = "helsinki"
        @listing.origin_and_destination_close_enough?(other_listing).should be_true
        
      end
      
      it "should return true, when comparing listings with origin and destination exact same string, but not found on map." do
        other_listing = FactoryGirl.build(:listing)
        other_listing.category = "rideshare"
        other_listing.origin = "Otski"
        other_listing.destination = "Taikki"
        @listing.origin = "Otski"
        @listing.destination = "Taikki"
        @listing.origin_and_destination_close_enough?(other_listing).should be_true
        
      end


      # This is commented away now as it the feature is currently not used and it caused trouble in Travis CI
      # it "should return true, when comparing listings with origin exactly same and destination close enough." do
      #   other_listing = FactoryGirl.build(:listing)
      #   other_listing.category = "rideshare"
      #   other_listing.origin = "Skatta"
      #   other_listing.destination = "simonkatu 4"
      #   @listing.origin = "Skatta"
      #   @listing.destination = "Helsinki"
      #   @listing.origin_and_destination_close_enough?(other_listing).should be_true
      #   
      # end
      
      it "should return false when comparing places too far away (either destination or origin)" do
        sleep 1 # without this there might be too many requests going to gmaps API and it will respond "over quota limit".
        other_listing = FactoryGirl.build(:listing)
        other_listing.category = "rideshare"
        other_listing.origin = "Otakaari 20"
        other_listing.destination = "Vilhonvuorenkatu 3"
        @listing.destination = "Espoon keskus"
        @listing.origin_and_destination_close_enough?(other_listing).should be_false
      end
      
      it "returns true even with long distances if differences are small enough" do
        other_listing = FactoryGirl.build(:listing)
        other_listing.category = "rideshare"
        other_listing.origin = "Lahti"
        other_listing.destination = "Oulu"
        @listing.destination = "Rovaniemi"
        @listing.origin_and_destination_close_enough?(other_listing).should be_true
      end
      
      it "should handle location nicknames in Helsinki if journey planner in use" do
        other_listing = FactoryGirl.build(:listing)
        other_listing.category = "rideshare"
        other_listing.origin = "dipoli"
        other_listing.destination = "taik"
        @listing.origin = "otski"
        @listing.destination = "arabianranta"
        response = @listing.origin_and_destination_close_enough?(other_listing)
        if APP_CONFIG.journey_planner_username
          response.should be_true
        else
          response.should be_false
        end  
      end
      
      
    end
    if APP_CONFIG.use_sms 
      describe "#inform_requester_about_potential_match" do
        context "When driver has a phone number in profile" do
          it "should send sms including driver's phone number and offer url" do
            offer = FactoryGirl.build(:listing)
            request = FactoryGirl.build(:listing)
            author = FactoryGirl.build(:person)
            request_author = FactoryGirl.build(:person)
            offer.id = 13
            offer.category = "rideshare"
            offer.origin = "Otakaari 20"
            offer.destination = "Vilhonvuorenkatu 3"
            offer.listing_type = "offer"
            offer.author = author
            request.listing_type = "request"
            request.author = request_author
            
            SmsHelper.should_receive(:send).with(/Danny.+Otakaari 20.+ Vilhonvuorenkatu 3 .+ 358507654321.+ http:\/\/.+ /, request_author.phone_number).and_return(true)
            
            author.should_receive(:phone_number).twice.and_return("358507654321")
            author.should_receive(:given_name).twice.and_return("Danny")
            
            request.inform_requester_about_potential_match(request, offer)
            
          end        
        end
      
        context "When driver doesn't have a phone number in profile" do
          it "should send sms including offers url" do
            offer = FactoryGirl.build(:listing)
            request = FactoryGirl.build(:listing)
            author = FactoryGirl.build(:person)
            request_author = FactoryGirl.build(:person)
            offer.id = 15
            #author.phone_number = nil
            
            if APP_CONFIG.bitly_username && APP_CONFIG.bitly_key
              SmsHelper.should_receive(:send).with(/ http:\/\/bit.ly\/.+ /, request_author.phone_number).and_return(true)
            else
              SmsHelper.should_receive(:send).with(/ http:\/\/.+\/#{offer.id} /, request_author.phone_number).and_return(true)
            end
            
            author.should_receive(:phone_number).once.and_return(nil)
            offer.listing_type = "offer"
            offer.author = author
            request.listing_type = "request"
            request.author = FactoryGirl.build(:person)
            
            request.inform_requester_about_potential_match(request, offer)
          end
        end
      
      end
    end
  end
  
  private
  
  def valid_with_share_types
    if Listing::VALID_SHARE_TYPES[@listing.listing_type][@listing.category]
      Listing::VALID_SHARE_TYPES[@listing.listing_type][@listing.category].each do |st|
        @listing.share_type = st
        @listing.should be_valid
      end
    end  
  end
  
  def listing_is_valid_with_correct_share_type(listing_type, category)
    @listing.listing_type = listing_type
    @listing.category = category
    valid_with_share_types
  end
  
  def listing_is_not_valid_with_incorrect_share_type(listing_type, category, share_type)
    @listing.listing_type = listing_type
    @listing.category = category
    @listing.share_type = share_type
    @listing.should_not be_valid
  end
  
end 