# == Schema Information
#
# Table name: conversations
#
#  id              :integer          not null, primary key
#  title           :string(255)
#  listing_id      :integer
#  created_at      :datetime
#  updated_at      :datetime
#  last_message_at :datetime
#  community_id    :integer
#  starting_page   :string(255)
#
# Indexes
#
#  index_conversations_on_community_id     (community_id)
#  index_conversations_on_last_message_at  (last_message_at)
#  index_conversations_on_listing_id       (listing_id)
#  index_conversations_on_starting_page    (starting_page)
#
class ConversationSerializer < ActiveModel::Serializer
   attributes :id, :title, :listing_id, :created_at, :updated_at, :last_message_at, :community_id, :starting_page


end