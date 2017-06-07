class ListingComment < ApplicationRecord
end

class MigrateListingCommentsForKassi2 < ActiveRecord::Migration
  def self.up

    say  "This migration simply makes a comment from each listing_comment."
    say "This does NOT DELETE the data from listing_comments", true
    ListingComment.all.each do |listing_comment|
      comment = Comment.new(:author_id => listing_comment.author_id,
                            :listing_id => listing_comment.listing_id,
                            :content => listing_comment.content,
                            :created_at => listing_comment.created_at)
      comment.save!
      comment.update_attribute("updated_at", listing_comment.updated_at)
      print "."; STDOUT.flush
    end
  end

  def self.down
    say "This migration just copied data from listing_comments to comments."
    say "Rolling back doesn't do anything.", true
  end
end
