class MailWorker < Workling::Base

  include VisibilityHelper

  # When new listing is posted, send mail to the users
  # who are friends with the listing author
  def send_mail_to_friends_about_listing(options)
    listing = Listing.find(options[:listing_id])
    cookie = options[:cookie]
    # Send mail to a friend only if he/she is allowed to see the listing and has
    # allowed mail notifications of new listings from friends.
    listing.author.friends(cookie).each do |friend|
      count = Listing.count(:all, :conditions => ["id = ?" + get_visibility_conditions("listing", friend, cookie), options[:listing_id]])
      if friend.settings.email_when_new_listing_from_friend == 1 && count == 1
        UserMailer.deliver_notification_of_new_listing_from_friend(listing, friend, options[:protocol], options[:host])
      end  
    end
  end
  
  def send_mail_about_comment_to_listing(options)
    comment = ListingComment.find(options[:comment_id])
    if comment.author.id != comment.listing.author.id && comment.listing.author.settings.email_when_new_comment == 1
      UserMailer.deliver_notification_of_new_comment(comment, options[:protocol], options[:host])
    end
    comment.listing.notify_followers(options[:protocol], options[:host], comment.author, false)
  end
  
  def send_mail_about_update_of_listing(options)
    listing = Listing.find(options[:listing_id])
    listing.notify_followers(options[:protocol], options[:host], listing.author, true)
  end

end