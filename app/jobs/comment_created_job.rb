class CommentCreatedJob < Struct.new(:comment_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have community_id parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    comment = Comment.find(comment_id)
    community = Community.find(community_id)
    comment.send_notifications(community)
    Badge.assign_with_levels("commentator", comment.author.authored_comments.count, comment.author, [3, 10, 30], community)
    EventFeedEvent.create(:person1_id => comment.author.id, :eventable_id => comment_id, :eventable_type => "Comment", :community_id => community_id, :category => "comment", :members_only => !comment.listing.public?)
  end

end
