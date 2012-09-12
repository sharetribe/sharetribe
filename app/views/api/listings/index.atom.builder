atom_feed :language => 'en-US' do |feed|
  feed.title @title
  feed.updated @updated

  @listings.each do |item|
    #next if item.updated_at.blank?

    feed.entry( item ) do |entry|
      entry.url listing_url(item)
      entry.title item.title
      entry.content item.description, :type => 'html'

      # the strftime is needed to work with Google Reader.
      entry.updated(item.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) 

      entry.author do |author|
        author.name item.author.name
      end
    end
  end
end