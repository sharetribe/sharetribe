class InsertMockListingsToDb < ActiveRecord::Migration
  def self.up
    listing_data = []
    listing_data[0] = {
      :author_id => "Kusti", 
      :category => "sell", 
      :title => "Myydään tietokone", 
      :content => "Myydään erinomainen tietokone. Tulkaa ostamaan.", 
      :good_thru => "2008-09-08", 
      :status => "open",
      :language => ["en-US"],
      :times_viewed => "0"
    }
    listing_data[1] = {
      :author_id => "Jaakko", 
      :category => "borrow_items", 
      :title => "Lainataan pora", 
      :content => "Tarvitaan pora lainaan mahdollisimman pikaisesti.", 
      :good_thru => "2008-09-08", 
      :status => "open",
      :language => ["en-US","swe"],
      :times_viewed => "0"
    }
    listing_data.each do |data|
      listing = Listing.create(data)
    end    
  end

  def self.down
  end
end
