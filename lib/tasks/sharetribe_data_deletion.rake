# Marketplace data deletion tasks
# DANGER! Tasks here result in data being permanently deleted.

namespace :sharetribe do

  def confirm!(message)
    print "#{message} (yes/no) "
    $stdout.flush
    input = $stdin.gets.chomp
    unless input == 'yes'
      raise "Task aborted."
    end
  end

  # rubocop:disable MethodLength
  def delete_marketplace_queries(id)
  sql = <<~SQL
    UPDATE communities SET deleted = 1 WHERE id = #{id};

    DELETE FROM feature_flags WHERE community_id = #{id};

    DELETE FROM community_translations WHERE community_id = #{id};

    DELETE mlt, ml
      FROM menu_link_translations mlt LEFT JOIN menu_links ml
        ON mlt.menu_link_id = ml.id
      WHERE ml.community_id = #{id};

    DELETE loc FROM locations loc
      LEFT JOIN people p ON loc.person_id = p.id
      WHERE p.community_id = #{id};

    DELETE loc FROM locations loc
      LEFT JOIN listings l ON loc.listing_id = l.id
      WHERE l.community_id = #{id};

    DELETE FROM locations WHERE community_id = #{id};

    DELETE li FROM listing_images li
      LEFT JOIN listings l ON li.listing_id = l.id
      WHERE l.community_id = #{id};

    DELETE fr
      FROM follower_relationships fr
      LEFT JOIN people p ON fr.person_id = p.id
      WHERE p.community_id = #{id};

    DELETE lf
      FROM listing_followers lf
      LEFT JOIN listings l ON lf.listing_id = l.id
      WHERE l.community_id = #{id};

    DELETE lts
      FROM listing_working_time_slots lts
      LEFT JOIN listings l ON lts.listing_id = l.id
      WHERE l.community_id = #{id};

    DELETE cfos
      FROM custom_field_option_selections cfos
      LEFT JOIN listings l ON cfos.listing_id = l.id
      WHERE l.community_id = #{id};

    DELETE cfv
      FROM custom_field_values cfv
      LEFT JOIN listings l ON cfv.listing_id = l.id
      WHERE l.community_id = #{id};

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

    DELETE FROM emails WHERE community_id = #{id};

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

    DELETE FROM marketplace_plans WHERE community_id = #{id};

    DELETE FROM marketplace_trials WHERE community_id = #{id};

    DELETE FROM listings WHERE community_id = #{id};

    DELETE lu
      FROM listing_units lu
      LEFT JOIN listing_shapes ls ON lu.listing_shape_id = ls.id
      WHERE ls.community_id = #{id};

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

    DELETE cfv
      FROM custom_field_values cfv
      LEFT JOIN custom_fields cf ON cfv.custom_field_id = cf.id
      WHERE cf.community_id = #{id};

    DELETE cfos
      FROM custom_field_option_selections cfos
      LEFT JOIN custom_field_options cfo ON cfos.custom_field_option_id = cfo.id
      LEFT JOIN custom_fields cf ON cfo.custom_field_id = cf.id
      WHERE cf.community_id = #{id};

    DELETE cfot, cfo
      FROM custom_field_option_titles cfot
      LEFT JOIN custom_field_options cfo ON cfo.id = cfot.custom_field_option_id
      LEFT JOIN custom_fields cf ON cfo.custom_field_id = cf.id
      WHERE cf.community_id = #{id};

    DELETE FROM custom_fields WHERE community_id = #{id};

    DELETE FROM people WHERE community_id = #{id};

    DELETE FROM stripe_accounts WHERE community_id = #{id};

    DELETE FROM payment_settings WHERE community_id = #{id};

    DELETE FROM community_memberships WHERE community_id = #{id};
SQL

  sql.split(/;/).map { |q| q.strip }.reject { |q| q.empty? }
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

  namespace :marketplace do
    desc "DANGER: Deletes all marketplace data. There is no going back. Stripe Connect accounts are not deleted in Stripe."
    task :delete, [:marketplace_id, :force, :skip_delete_images] => [:environment] do |t, args|
      marketplace_id = args[:marketplace_id]
      force = (args[:force] == "true") || false
      skip_delete_images = (args[:skip_delete_images] == "true") || false

      unless marketplace_id =~ /^\d+$/
        raise "Invalid marketplace id."
      end

      community = Community.find(marketplace_id)

      puts "Will delete all data for marketplace #{community.ident}, ID #{community.id}!"
      puts "THIS CAN NOT BE UNDONE!"
      force || confirm!("Are you sure you want to delete all data for this marketplace?")

      community.deleted = true
      community.save

      unless skip_delete_images
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

      # Clean up all data in database
      puts "Deleting all marketplace data in the database..."
      delete_marketplace_queries(marketplace_id).each do |q|
        puts "#{q};"
        ActiveRecord::Base.connection.execute(q)
      end

      puts "Done."
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
