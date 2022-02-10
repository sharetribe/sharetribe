namespace :export do

  def print_image_urls(image)
    return unless image.present?

    image.styles.each { |s, _| puts image.url(s) }
  end

  def print_current_clp_images(community_id)
    return unless CustomLandingPage::LandingPageStore.enabled?(community_id)

    released_version = CustomLandingPage::LandingPageStore.released_version(community_id)
    structure = CustomLandingPage::LandingPageStore.load_structure(community_id, released_version)

    # Build direct S3 URL, instead of the CDN one, so that image paths maintain
    # the sites/COMMUNITY_ID prefix. This helps the data export script to
    # organize the downloaded images correctly.
    assets = structure["assets"]
    assets.select { |a| a["content_type"].match(/^image\//) }.map do |image|
      puts "https://#{APP_CONFIG.clp_s3_bucket_name}.s3.amazonaws.com/sites/#{community_id}/#{image['src']}"
    end
  end

  desc 'Prints out a list of all the URLs of all uploaded files of the community whose ID is given as parameter'
  task :community_image_urls, [:community_id, :include_clp_images] => :environment do |t, args|
    community_id = args[:community_id]
    include_clp_images = args[:include_clp_images].to_s.casecmp("true").zero?
    community = Community.find(community_id)

    puts "\n# Marketplace images"

    print_image_urls(community.cover_photo)
    print_image_urls(community.small_cover_photo)
    print_image_urls(community.logo)
    print_image_urls(community.wide_logo)
    print_image_urls(community.favicon)

    if include_clp_images
      puts "\n#CLP images"
      print_current_clp_images(community_id)
    end

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
    # Make sure this string is printed in the end. It is used to verify the
    # image list export.
    puts "\n# ::image-export-end::"
  end

end
