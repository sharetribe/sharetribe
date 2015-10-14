module ListingIndexService::Search

  class ZappyAdapter < SearchEngineAdapter

   def initialize
     @conn = Faraday.new(url: "http://127.0.0.1:8080") do |c|
        c.request  :url_encoded             # form-encode POST params
        c.response :logger                  # log requests to STDOUT
        c.response :json, :content_type => /\bjson$/
        c.adapter  Faraday.default_adapter  # make requests with Net::HTTP
     end
   end

   def search(community_id:, search:, includes: nil)

     begin
       res = @conn.get('/search', {community_id: community_id, keywords: search[:keywords]}).body
       Result::Success.new(parse_response(res))
     rescue StandardError => e
       Result::Error.new(e)
     end
   end


   private

   def parse_response(res)
     {count: res.count,
      listings: res.map { |l| parse_listing(l) }}
   end

   def parse_author(author_res)
     author_res = HashUtils.symbolize_keys(author_res)
     {id: author_res[:id],
      username: author_res[:username],
      first_name: author_res[:given_name],
      last_name: author_res[:family_name],
      organization_name: "N/A", # Missing from index
      is_organization: false, # Missing from index
      avatar: { thumb: nil } # Incorrect format for images in index
     }
   end

   def parse_listing(listing_res)
     listing_res = HashUtils.symbolize_keys(listing_res)
     listing_res
       .slice(:id, :title, :description, :updated_at, :created_at)
       .merge({category_id: 1, # Missing from index
               author: parse_author(listing_res[:author]),
               listing_images: []}) # Incorrect format for images in index
   end


  end
end
