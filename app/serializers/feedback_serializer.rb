# == Schema Information
#
# Table name: feedbacks
#
#  id           :integer          not null, primary key
#  content      :text(65535)
#  author_id    :string(255)
#  url          :string(2048)
#  created_at   :datetime
#  updated_at   :datetime
#  is_handled   :integer          default(0)
#  email        :string(255)
#  community_id :integer
#

class FeedbackSerializer < ActiveModel::Serializer
    attributes :id,:content,:author_id,:url,:created_at,:updated_at,:is_handled,:email,:community_id
end