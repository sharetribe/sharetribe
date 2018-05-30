namespace :export do

  def print_image_urls(image)
    return unless image.present?

    image.styles.each { |s, _| puts image.url(s) }
  end

  desc 'Prints out a list of all the URLs of all uploaded files of the community whose ID is given as parameter'
  task :community_image_urls, [:community_id] => :environment do |t, args|
    community_id = args[:community_id]
    community = Community.find(community_id)

    puts "\n# Marketplace images"

    print_image_urls(community.cover_photo)
    print_image_urls(community.small_cover_photo)
    print_image_urls(community.logo)
    print_image_urls(community.wide_logo)
    print_image_urls(community.favicon)

    puts "\n# Profile pictures"
    community.members.find_each do |member|
      print_image_urls(member.image)
    end

    puts "\n# Listing images"
    community.listings.find_each do |listing|
      listing.listing_images.each do |listing_image|
        print_image_urls(listing_image.image)
      end
    end

  end

end
