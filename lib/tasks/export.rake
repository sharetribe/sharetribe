namespace :export do

  desc 'Prints out a list of all the URLs of all uploaded files of the community whose ID is given as parameter'
  task :community_image_urls, [:community_id] => :environment do |t, args|
    community_id = args[:community_id]
    community = Community.find(community_id)

    puts "\n# Marketplace images"

    if community.cover_photo.present?
      puts community.cover_photo.url(:header)
      puts community.cover_photo.url(:hd_header)
      puts community.cover_photo.url(:original)
    end

    if community.small_cover_photo.present?
      puts community.small_cover_photo.url(:header)
      puts community.small_cover_photo.url(:hd_header)
      puts community.small_cover_photo.url(:original)
    end

    if community.logo.present?
      puts community.logo.url(:header)
      puts community.logo.url(:header_icon)
      puts community.logo.url(:header_icon_highres)
      puts community.logo.url(:apple_touch)
      puts community.logo.url(:original)
    end

    if community.wide_logo.present?
      puts community.wide_logo.url(:header)
      puts community.wide_logo.url(:header_highres)
      puts community.wide_logo.url(:original)

    end

    if community.favicon.present?
      puts community.favicon.url
    end

    puts "\n# Profile pictures"
    community.members.find_each do |member|
      if member.image.present?
        puts member.image.url(:medium)
        puts member.image.url(:small)
        puts member.image.url(:thumb)
        puts member.image.url(:original)
      end
    end

    puts "\n# Listing images"
    community.listings.find_each do |listing|
      listing.listing_images.each do |listing_image|
        if listing_image.image.present?
          puts listing_image.image.url(:small_3x2)
          puts listing_image.image.url(:medium)
          puts listing_image.image.url(:thumb)
          puts listing_image.image.url(:original)
          puts listing_image.image.url(:big)
          puts listing_image.image.url(:email)
        end
      end
    end

  end

end
