namespace :clp do
  desc 'Copy any CLP images with ident in the path to corresponding key using community ID instead.'
  task :migrate_images, [:noop] => :environment do |t, args|

    noop = (args[:noop] == "true") || false

    s3 = Aws::S3::Client.new(
      region: APP_CONFIG.s3_region,
      access_key_id: APP_CONFIG.aws_access_key_id,
      secret_access_key: APP_CONFIG.aws_secret_access_key
    )

    bucket = Aws::S3::Bucket.new(APP_CONFIG.clp_s3_bucket_name, {client: s3})

    keys = bucket.objects.map { |o| o.key }.to_set

    old_to_new = keys.map { |k|
      match = k.match(/^sites\/([^\/]*[a-z][^\/]*)\//)
      [k, match ? match[1] : nil ]
    }.select { |k, ident| ident }.map { |k, ident|
      c = Community.find_by_ident(ident)

      if c
        [k, k.gsub(/^(sites\/)([^\/]*[a-z][^\/]*)(\/.*)$/, "\\1#{c.id}\\3")]
      else
        puts "Community with ident #{ident} not found" unless c
      end
    }.select { |k, new_k| new_k }.to_h

    new_style_keys = keys.select { |k|
      k.match(/^sites\/([0-9]+)/)
    }.to_set

    pending = old_to_new.values.to_set - new_style_keys

    new_to_old = old_to_new.invert

    puts "#{pending.count} pending objects"

    pending.each do |k|
      begin
        noop_suf = noop ? " (noop)" : ""
        puts "Copying #{new_to_old[k]} to #{k}#{noop_suf}"
        unless noop
          s3.copy_object({
                           bucket: APP_CONFIG.clp_s3_bucket_name,
                           copy_source: "/#{APP_CONFIG.clp_s3_bucket_name}/#{new_to_old[k]}",
                           key: k,
                           acl: "public-read"
                         })
        end
      rescue StandardError => e
        puts "Error copying object #{new_to_old[k]} to #{k}: #{e}"
      end
    end
  end
end
