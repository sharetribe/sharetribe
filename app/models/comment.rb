# == Schema Information
#
# Table name: comments
#
#  id           :integer          not null, primary key
#  author_id    :string(255)
#  listing_id   :integer
#  content      :text(65535)
#  created_at   :datetime
#  updated_at   :datetime
#  community_id :integer
#
# Indexes
#
#  index_comments_on_listing_id  (listing_id)
#

class Comment < ApplicationRecord

  belongs_to :author, :class_name => "Person"
  belongs_to :listing, :counter_cache => true

  attr_accessor :author_follow_status

  validates_length_of :content, :minimum => 1, :maximum => 5000, :allow_nil => false

  after_create :update_follow_status

  # Creates notifications related to this comment and sends notification emails
  def send_notifications(community)
    if !listing.author.id.eql?(author.id)
      if listing.author.should_receive?("email_about_new_comments_to_own_listing")
        MailCarrier.deliver_now(PersonMailer.new_comment_to_own_listing_notification(self, community))
      end
    end
    listing.notify_followers(community, author, false)
  end

  def update_follow_status
    if listing
      author.update_follow_status(listing, author_follow_status)
    end
  end

end
