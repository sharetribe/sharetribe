# Community-aware stylesheet compiler.
#
# Provides two public methods:
#
# - `compile_all` Compiles all custom stylesheets for all communities
#   that have customizations
# - `compile(community)` Compiles stylesheet only for the given community
#
module CommunityStylesheetCompiler
  SOURCE_DIR = "app/assets/stylesheets"
  SOURCE_FILE = "application.scss"
  TARGET_DIR = "public/assets"
  VARIABLE_FILE = "mixins/default-colors.scss"
  S3_PATH = "assets/custom"

  class << self

    def compile_all(delayed_opts={})
      prepare_compile_all do |community|
        Delayed::Job.enqueue(CompileCustomStylesheetJob.new(community.id), delayed_opts)
      end
    end

    def compile_all_immediately
      prepare_compile_all do |community|
        CommunityStylesheetCompiler.compile(community)
      end
    end

    # Compile stylesheet, upload to S3 (if needed) and update stylesheet_url
    # value in database
    def compile(community)
      return unless community.has_customizations?

      prepare

      variable_hash = create_variable_hash(community)
      target_file_basename = create_new_filename(community.domain)
      target_file_extension = use_gzip? ? "css.gz" : "css"
      target_file_path = "public/assets/#{target_file_basename}.#{target_file_extension}"

      StylesheetCompiler.compile(SOURCE_DIR, SOURCE_FILE, target_file_path, VARIABLE_FILE, variable_hash)

      # Save URL without extension for Rails helpers

      url = if ApplicationHelper.use_s3?
        sync(target_file_path, target_file_basename)
      else
        # Save file without extension for Rails helpers
        target_file_basename
      end

      # If we are at preproduction, only update the preproduction_stylesheet_url in order not
      # to disturb what's happening at production.
      # Normally update the stylesheet_url
      if APP_CONFIG.preproduction
        community.update_attribute(:preproduction_stylesheet_url, url)
      else
        community.update_attribute(:stylesheet_url, url)
      end

      community.update_attribute(:stylesheet_needs_recompile, false)
    end

    private

    def prepare_compile_all(&block)
      puts "Reset all custom CSS urls"
      Community.stylesheet_needs_recompile!

      with_customizations_prioritized = Community.with_customizations.order("members_count DESC")

      puts "Genarete custom CSS for #{with_customizations_prioritized.count} communities"
      with_customizations_prioritized.each &block
    end

    def use_gzip?
      # Don't use gzip locally
      ApplicationHelper.use_s3?
    end

    # If using S3 as storage (e.g. in Heroku) need to move the generated files to S3
    def sync(file_path, file_basename)
      AWS.config :access_key_id =>  APP_CONFIG.aws_access_key_id,  :secret_access_key => APP_CONFIG.aws_secret_access_key
      basename = File.basename("#{file_path}")
      s3 = AWS::S3.new
      o = get_or_create_bucket(s3, APP_CONFIG.s3_bucket_name).objects[s3_file_path(file_basename)]
      o.write(:file => "#{Rails.root}/#{file_path}", :cache_control => "public, max-age=30000000", :content_type => "text/css", :content_encoding => "gzip")
      o.acl = :public_read
      o.public_url.to_s
    end

    # First check if the specified bucket exists, otherwise create it. This is needed to support EU buckets.
    # (EU buckets error if you try to create an existing one. US buckets won't.)
    def get_or_create_bucket(s3, bucket_name)
      bucket_from_config = s3.buckets[bucket_name]
      bucket_from_config.exists? ? bucket_from_config : s3.buckets.create(bucket_name)
    end

    # Give source file basename (i.e. filename without extension)
    # and get back S3 path
    def s3_file_path(file_basename)
      # Save file as .css even though it is gzip. This way older
      # Safaris are able to load the gzipped file.
      filename = file_basename + ".css"
      File.join(S3_PATH, filename)
    end

    def prepare
      `mkdir #{TARGET_DIR}` unless File.exists?(TARGET_DIR)
    end

    def to_color(val)
      val.present? ? "##{val}" : nil
    end

    def image_to_string(image, style)
      url = image.url(style)
      image.present? ? "\"#{url}\"" : nil
    end

    def create_variable_hash(community)
      color1 = community.custom_color1
      color2 = community.custom_color2 || community.custom_color1


      hash = {
        "link"                    => to_color(color1),
        "link2"                   => to_color(color2),
        "cover-photo-url"         => image_to_string(community.cover_photo, :hd_header),
        "small-cover-photo-url"   => image_to_string(community.small_cover_photo, :hd_header),
        "wide-logo-lowres-url"    => image_to_string(community.wide_logo, :header),
        "wide-logo-highres-url"   => image_to_string(community.wide_logo, :header_highres),
        "square-logo-lowres-url"  => image_to_string(community.logo, :header_icon),
        "square-logo-highres-url" => image_to_string(community.logo, :header_icon_highres)
      }

      HashUtils.compact(hash)
    end

    def create_new_filename(domain)
      community_domain = domain.gsub(".", "_")
      timestamp = Time.now.strftime("%Y%m%d%H%M%S")
      "custom-style-#{community_domain}-#{timestamp}"
    end
  end
end
