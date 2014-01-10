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
  VARIABLE_FILE = "default-colors.scss"

  class << self

    def compile_all
      puts "Reset all custom CSS urls"
      Community.reset_custom_stylesheets!

      with_customizations_prioritized = Community.with_customizations.order("members_count DESC")

      puts "Genarete custom CSS for #{with_customizations_prioritized.count} communities"
      with_customizations_prioritized.each do |community|
        Delayed::Job.enqueue(CompileCustomStylesheetJob.new(community.id))
      end
    end

    # Compile stylesheet, upload to S3 (if needed) and update stylesheet_url
    # value in database
    def compile(community)
      return unless community.has_customizations?

      prepare

      variable_hash = create_variable_hash(community)
      target_file_no_ext = create_new_filename(community.domain)
      target_file_path = "public/assets/#{target_file_no_ext}.css"

      StylesheetCompiler.compile(SOURCE_DIR, SOURCE_FILE, target_file_path, VARIABLE_FILE, variable_hash)

      url = sync(target_file_path) || target_file_no_ext
      # If we are at preproduction, only update the preproduction_stylesheet_url in order not
      # to disturb what's happening at production.
      # Normally update the stylesheet_url
      if APP_CONFIG.preproduction
        community.update_attribute(:preproduction_stylesheet_url, url)        
      else
        community.update_attribute(:stylesheet_url, url)
      end
    end

    private

    # If using S3 as storage (e.g. in Heroku) need to move the generated files to S3
    def sync(target_file_path)
      if ApplicationHelper.use_s3?
        AWS.config :access_key_id =>  APP_CONFIG.aws_access_key_id,  :secret_access_key => APP_CONFIG.aws_secret_access_key
        s3 = AWS::S3.new
        b = s3.buckets.create(APP_CONFIG.s3_bucket_name)
        basename = File.basename("#{Rails.root}/#{target_file_path}")
        o = b.objects["assets/custom/#{basename}"]
        o.write(:file => "#{Rails.root}/#{target_file_path}", :cache_control => "public, max-age=30000000", :content_type => "text/css")
        o.acl = :public_read
        o.public_url.to_s
      end
    end

    def prepare
      `mkdir #{TARGET_DIR}` unless File.exists?(TARGET_DIR)
    end

    def to_color(val)
      val.present? ? "##{val}" : nil
    end

    def to_string(val)
      val.present? ? "\"#{val}\"" : nil
    end

    def create_variable_hash(community)
      color1 = community.custom_color1
      color2 = community.custom_color2 || community.custom_color1

      hash = {
        "link"                  => to_color(color1),
        "link2"                 => to_color(color2),
        "cover-photo-url"       => to_string(community.cover_photo.url(:hd_header)),
        "small-cover-photo-url" => to_string(community.small_cover_photo.url(:hd_header))
      }

      Util::Hash.compact(hash)
    end

    def create_new_filename(domain)
      community_domain = domain.gsub(".", "_")
      timestamp = Time.now.strftime("%Y%m%d%H%M%S")
      "custom-style-#{community_domain}-#{timestamp}"
    end
  end
end