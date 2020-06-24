# Marketplace data deletion tasks
# DANGER! Tasks here result in data being permanently deleted.

# Number of days after which old marketplaces and trials are soft-deleted
# (simply flagged as deleted)
DATA_SOFT_DELETION_DAYS_THRESHOLD = 180

# Number of days to keep old marketplaces and trials
DATA_DELETION_DAYS_THRESHOLD = 365

# Sleep time between deletion of marketplace users and listings
# Affects DB and Indexer load significantly
DEFAULT_SLEEP_TIME = 1.5
# Sleep time between raw SQL queries for full data cleanup
DEFAULT_QUERY_SLEEP_TIME = 0.2

namespace :sharetribe do

  def confirm!(message)
    print "#{message} (yes/no) "
    $stdout.flush
    input = $stdin.gets.chomp
    unless input == 'yes'
      raise "Task aborted."
    end
  end

  def old_marketplaces_with_plans(date, ignore_deleted = false)
    query = <<~SQL
      SELECT DISTINCT
          mp.community_id
          ,mp.expires_at
      FROM marketplace_plans mp
      INNER JOIN (
          SELECT mp.community_id, MAX(mp.created_at) AS max_created_at
          FROM marketplace_plans mp
          GROUP BY mp.community_id
      ) mp2 -- Keeps only the latest value/row
      ON mp.community_id = mp2.community_id AND mp.created_at = mp2.max_created_at
      LEFT JOIN communities c
      ON mp.community_id = c.id
      WHERE 1=1
        #{ignore_deleted ? 'AND (c.deleted = 0 OR c.deleted IS NULL)' : ''}
      	AND mp.expires_at IS NOT NULL -- To be extra safe
      	AND mp.expires_at < '#{date}' -- Change to desired value
      ORDER BY 2;
    SQL
    r = ActiveRecord::Base.connection.execute(query)
    r.map { |row| row[0] }
  end

  def old_marketplace_trials(date, ignore_deleted = false)
    query = <<~SQL
      SELECT DISTINCT
          mt.community_id
          ,mt.expires_at
      FROM marketplace_trials mt
      INNER JOIN (
          SELECT mt.community_id, MAX(mt.created_at) AS max_created_at
          FROM marketplace_trials mt
          GROUP BY mt.community_id
      ) mt2 -- Keeps only the latest value/row
      ON mt.community_id = mt2.community_id AND mt.created_at = mt2.max_created_at
      LEFT JOIN marketplace_plans mp
      ON mt.community_id = mp.community_id
      LEFT JOIN communities c
      ON mt.community_id = c.id
      WHERE 1=1
        #{ignore_deleted ? 'AND (c.deleted = 0 OR c.deleted IS NULL)' : ''}
      	AND mp.community_id IS NULL -- Removes all trials with a plan in marketplace_plans
      	AND mt.expires_at IS NOT NULL -- To be extra safe
      	AND mt.expires_at < '#{date}' -- Change to desired value
      ORDER BY 2;
    SQL
    r = ActiveRecord::Base.connection.execute(query)
    r.map { |row| row[0] }
  end

  def delete_marketplace_queries_final(id)
    sql = <<~SQL
      DELETE FROM locations WHERE community_id = #{id};

      DELETE lu
        FROM listing_units lu
        LEFT JOIN listing_shapes ls ON lu.listing_shape_id = ls.id
        WHERE ls.community_id = #{id};

      DELETE FROM community_translations WHERE community_id = #{id};

      DELETE FROM listing_shapes WHERE community_id = #{id};

      DELETE ct
        FROM category_translations ct
        LEFT JOIN categories c ON ct.category_id = c.id WHERE c.community_id = #{id};

      DELETE ccf
        FROM category_custom_fields ccf
        LEFT JOIN categories c ON ccf.category_id = c.id
        WHERE c.community_id = #{id};

      DELETE cls
        FROM category_listing_shapes cls
        LEFT JOIN categories c ON cls.category_id = c.id
        WHERE c.community_id = #{id};

      DELETE FROM categories WHERE community_id = #{id};

      DELETE cfn
        FROM custom_field_names cfn
        LEFT JOIN custom_fields cf ON cfn.custom_field_id = cf.id
        WHERE cf.community_id = #{id};

      DELETE cfot, cfo
        FROM custom_field_option_titles cfot
        LEFT JOIN custom_field_options cfo ON cfo.id = cfot.custom_field_option_id
        LEFT JOIN custom_fields cf ON cfo.custom_field_id = cf.id
        WHERE cf.community_id = #{id};

      DELETE FROM custom_fields WHERE community_id = #{id};

      DELETE FROM marketplace_plans WHERE community_id = #{id};

      DELETE FROM marketplace_trials WHERE community_id = #{id};
    SQL

    sql.split(/;/).map { |q| q.strip }.reject { |q| q.empty? }
  end

  def delete_marketplace_queries(id)
    sql = <<~SQL
      DELETE FROM feature_flags WHERE community_id = #{id};

      DELETE mlt, ml
        FROM menu_link_translations mlt LEFT JOIN menu_links ml
          ON mlt.menu_link_id = ml.id
        WHERE ml.community_id = #{id};

      DELETE fr
        FROM follower_relationships fr
        LEFT JOIN people p ON fr.person_id = p.id
        WHERE p.community_id = #{id};

      DELETE part
        FROM participations part
        LEFT JOIN people p ON part.person_id = p.id
        WHERE p.community_id = #{id};

      DELETE part
        FROM participations part
        LEFT JOIN conversations c ON part.conversation_id = c.id
        WHERE c.community_id = #{id};

      DELETE m, c
        FROM messages m
        LEFT JOIN conversations c ON m.conversation_id = c.id
        WHERE c.community_id = #{id};

      DELETE FROM conversations WHERE community_id = #{id};

      DELETE b
        FROM bookings b
        LEFT JOIN transactions t ON b.transaction_id = t.id
        WHERE t.community_id = #{id};

      DELETE op
        FROM order_permissions op
        LEFT JOIN paypal_accounts pa ON op.paypal_account_id = pa.id
        WHERE pa.community_id = #{id};

      DELETE ba
        FROM billing_agreements ba
        LEFT JOIN paypal_accounts pa ON ba.paypal_account_id = pa.id
        WHERE pa.community_id = #{id};

      DELETE FROM paypal_accounts WHERE community_id = #{id};

      DELETE tt
        FROM transaction_transitions tt
        LEFT JOIN transactions t ON tt.transaction_id = t.id
        WHERE t.community_id = #{id};

      DELETE sa
        FROM shipping_addresses sa
        LEFT JOIN transactions t ON sa.transaction_id = t.id
        WHERE t.community_id = #{id};

      DELETE FROM transaction_process_tokens WHERE community_id = #{id};

      DELETE FROM transactions WHERE community_id = #{id};

      DELETE FROM transaction_processes WHERE community_id = #{id};

      DELETE t
        FROM testimonials t
        LEFT JOIN people p ON t.author_id = p.id
        WHERE p.community_id = #{id};

      DELETE c
        FROM comments c
        LEFT JOIN listings l ON c.listing_id = l.id
        WHERE l.community_id = #{id};

      DELETE FROM active_sessions WHERE community_id = #{id};

      DELETE FROM community_customizations WHERE community_id = #{id};

      DELETE FROM feedbacks WHERE community_id = #{id};

      DELETE FROM invitations WHERE community_id = #{id};

      DELETE FROM invitation_unsubscribes WHERE community_id = #{id};

      DELETE FROM landing_page_versions WHERE community_id = #{id};

      DELETE FROM landing_pages WHERE community_id = #{id};

      DELETE FROM marketplace_sender_emails WHERE community_id = #{id};

      DELETE FROM marketplace_setup_steps WHERE community_id = #{id};

      DELETE FROM marketplace_configurations WHERE community_id = #{id};

      DELETE pr
        FROM paypal_refunds pr
        LEFT JOIN paypal_payments pp ON pr.paypal_payment_id = pp.id
        WHERE pp.community_id = #{id};

      DELETE FROM paypal_payments WHERE community_id = #{id};

      DELETE FROM stripe_payments WHERE community_id = #{id};

      DELETE FROM stripe_accounts WHERE community_id = #{id};

      DELETE FROM payment_settings WHERE community_id = #{id};

      DELETE FROM community_social_logos WHERE community_id = #{id};
    SQL

    sql.split(/;/).map { |q| q.strip }.reject { |q| q.empty? }
  end

  def delete_marketplace_db!(queries, sleep_time)
    queries.each do |q|
      sleep sleep_time
      puts "#{q};"
      ActiveRecord::Base.connection.execute(q)
    end
  end

  def s3_delete_objects(client, bucket, objects)
    res = client.delete_objects(
      bucket: bucket,
      delete: {
        objects: objects,
        quiet: true
      }
    ).to_h

    res[:errors]&.each { |e| puts "  #{e}"}
  end


  def delete_marketplace_images!(community)
    s3 = Aws::S3::Client.new(
      region: APP_CONFIG.s3_region,
      access_key_id: APP_CONFIG.aws_access_key_id,
      secret_access_key: APP_CONFIG.aws_secret_access_key
    )

    puts "Deleting marketplace images..."
    [:cover_photo, :small_cover_photo, :logo, :wide_logo, :favicon].flat_map { |i|
      image = community.send(i)
      image.present? && image.styles.map { |s, _| {key: image.s3_object(s).key} }
    }.select { |o| o }.each_slice(1000) { |objects|
      s3_delete_objects(s3, APP_CONFIG.s3_bucket_name, objects)
    }

    puts "Deleting marketplace social_logo..."
    social_logo = community.social_logo&.image
    if social_logo&.present?
      s3_delete_objects(s3,
                        APP_CONFIG.s3_bucket_name,
                        social_logo.styles.map { |s, _| {key: social_logo.s3_object(s).key} })
    end

    puts "Deleting profile images..."
    Person.where(community_id: community.id).flat_map { |p|
      p.image.present? && p.image.styles.map { |s, _| {key: p.image.s3_object(s).key} }
    }.select { |o| o }.each_slice(1000) { |objects|
      puts "  batch: #{objects.count}"
      s3_delete_objects(s3, APP_CONFIG.s3_bucket_name, objects)
    }

    puts "Deleting listing images..."
    Listing.where(community_id: community.id).flat_map { |l|
      l.listing_images.select { |i| i.image.present? }
    }.flat_map { |i|
      i.image.styles.map { |s, _| {key: i.image.s3_object(s).key }}
    }.each_slice(1000) { |objects|
      puts "  batch: #{objects.count}"
      s3_delete_objects(s3, APP_CONFIG.s3_bucket_name, objects)
    }
  end

  def progress(completed, total)
    "#{completed} / #{total}, #{(completed  * 100 / total).round(2)}%"
  end

  def soft_delete_marketplace!(community_id)
    community = Community.find_by_id(community_id)

    return unless community

    community.deleted = true
    community.save
    puts "Community #{community_id} marked as deleted"
  end

  def delete_marketplace_data!(community_id, sleep_time, query_sleep_time)
    community = Community.find_by_id(community_id)

    return unless community

    community.deleted = true
    community.save

    puts "Deleting data for community #{community.id}"

    delete_marketplace_images!(community)

    # Bulk delete non-indexed data
    delete_marketplace_db!(delete_marketplace_queries(community.id), query_sleep_time)

    total_count = community.listings.count + Person.where(community_id: community.id).count
    deleted_count = 1

    Listing.where(community_id: community.id).pluck(:id).each do |listing_id|
      begin
        sleep sleep_time
        puts "Deleting listing #{listing_id} from community #{community.id} (#{progress(deleted_count, total_count)})"
        deleted_count += 1

        # Listing images that have error are not destroyed when listing is
        # destroyed so delete them manually
        ListingImage.where(listing_id: listing_id).delete_all

        Listing.find(listing_id).destroy
      rescue StandardError => e
        puts "Destroy listing failed for #{listing_id}: #{e.message}"
      end
    end

    Person.where(community_id: community.id).pluck(:id).each do |person_id|
      begin
        sleep sleep_time
        puts "Deleting person #{person_id} from community #{community.id} (#{progress(deleted_count, total_count)})"
        deleted_count += 1

        Person.find(person_id).destroy
      rescue StandardError => e
        puts "Destroy person failed for #{person_id}: #{e.message}"
      end
    end

    delete_marketplace_db!(delete_marketplace_queries_final(community.id), query_sleep_time)
    puts "Deletion complete for community #{community.id}"
  end

  namespace :marketplace do
    desc "DANGER: Deletes all marketplace data. There is no going back. Stripe Connect accounts are not deleted in Stripe."
    task :delete, [:marketplace_id, :force] => [:environment] do |t, args|
      marketplace_id = args[:marketplace_id]
      force = (args[:force] == "true") || false

      unless marketplace_id =~ /^\d+$/
        raise "Invalid marketplace id."
      end

      community = Community.find(marketplace_id)

      puts "Will delete all data for marketplace #{community.ident}, ID #{community.id}!"
      puts "THIS CAN NOT BE UNDONE!"
      force || confirm!("Are you sure you want to delete all data for this marketplace?")

      community.deleted = true
      community.save

      # Create an "expired" trial so that the Shredder picks up and deletes the
      # marketplace
      PlanService::Store::Plan.delete_trials(community_id: community.id)
      PlanService::Store::Plan.delete_plans(community_id: community.id)
      PlanService::Store::Plan.create_trial(community_id: community.id, plan: {expires_at: 2.years.ago})

      puts "Done."
    end

    # NOTE: This task monkey-patches Paperclip::Storage::S3. See below.
    desc "DANGER: Run a continuous task that deletes all data for marketplaces with old expired trials or plans."
    task :run_shredder, [:sleep_time, :query_sleep_time] => [:environment] do |t, args|
      sleep_time = Maybe(args[:sleep_time]).to_f.or_else(DEFAULT_SLEEP_TIME)
      query_sleep_time = Maybe(args[:query_sleep_time]).to_f.or_else(DEFAULT_QUERY_SLEEP_TIME)

      # Prepare monkey patch for Paperclip so that it does not delete images
      # We handle image deletion more efficiently
      module Paperclip
        module Storage
          module S3
            def flush_deletes
              @queued_for_delete = []
            end

            def exists?(style)
              false
            end
          end
        end
      end

      loop do
        threshold_date = DATA_DELETION_DAYS_THRESHOLD.days.ago
        soft_delete_threshold_date = DATA_SOFT_DELETION_DAYS_THRESHOLD.days.ago

        # Soft delete marketplaces with expired paid plans
        old_marketplaces_with_plans(soft_delete_threshold_date, true).each do |mp_id|
          soft_delete_marketplace!(mp_id)
        end

        # Soft delete old trials
        old_marketplace_trials(soft_delete_threshold_date, true).each do |mp_id|
          soft_delete_marketplace!(mp_id)
        end

        # Delete any old expired paid marketplaces
        old_marketplaces_with_plans(threshold_date).each do |mp_id|
          delete_marketplace_data!(mp_id, sleep_time, query_sleep_time)
        end

        # Delete old trials
        old_marketplace_trials(threshold_date).each do |mp_id|
          delete_marketplace_data!(mp_id, sleep_time, query_sleep_time)
        end

        sleep 3600 * 6 # 6 hours
      end
    end

    desc "DANGER: Attempt to delete all Stripe Connect accounts for a marketplace."
    task :delete_stripe_accounts, [:marketplace_id, :force] => [:environment] do |t, args|
      marketplace_id = args[:marketplace_id]
      force = (args[:force] == "true") || false

      unless marketplace_id =~ /^\d+$/
        railse "Invalid marketplace id."
      end

      community = Community.find(marketplace_id)

      puts "Will delete all Stripe Connect accounts in marketplace #{community.ident}, ID #{community.id}!"
      puts "THIS CAN NOT BE UNDONE!"
      force || confirm!("Are you sure you want to delete all Stripe Connect accounts in this marketplace?")

      people = Person.where(community_id: marketplace_id)

      people.each do |person|
        stripe_acc = StripeAccount.where(person_id: person.id, community_id: community.id).first

        next unless stripe_acc

        puts "Deleting Stripe account for user #{person.id}..."
        stripe_res = StripeService::API::Api.accounts.delete_seller_account(community_id: community.id,
                                                                            person_id: person.id)
        unless stripe_res[:success]
          puts "WARN: Failed to delete Stripe account for user #{person.id}: #{stripe_acc.stripe_seller_id}"
        end
      end
      puts "Done."
    end
  end

end
