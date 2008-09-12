class InsertMockFavorsToDb < ActiveRecord::Migration
  def self.up
    favor_data = []
    favor_data[0] = {
      :owner_id => "Julia",  
      :title => "Lastenhoito apua", 
      :description => "Voin auttaa päivisin muutaman tunnin ajan, jos äiti haluaa käydä esim. hoitamassa asioita",
      :payment => 5
    }
    favor_data[1] = {
      :owner_id => "Antti",
      :title => "Kuljetusapua",
      :description => "Omistan auton ja voin auttaa esim. isojen ostosten kanssa tai vastaavaa. Ota yhteyttä puhelimitse!",
      :payment => 3
      
    }
    favor_data[2] = {
      :owner_id => "Antti",
      :title => "Ohjelmointiapua",
      :description => "",
      :payment => 4
    }
    favor_data[3] = {
      :owner_id => "Julia",
      :title => "Leivontaa",
      :description => "Tykkään leipoa, mutten jaksa syödä itse kaikkea",
      :payment => 3
    }
    
    favor_data.each do |info|
      favor = Favor.create(info)
    end
  end

  def self.down
  end
end
