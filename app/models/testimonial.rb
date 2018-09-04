# == Schema Information
#
# Table name: testimonials
#
#  id               :integer          not null, primary key
#  grade            :float(24)
#  text             :text(65535)
#  author_id        :string(255)
#  participation_id :integer
#  transaction_id   :integer
#  created_at       :datetime
#  updated_at       :datetime
#  receiver_id      :string(255)
#  blocked          :boolean          default(FALSE)
#
# Indexes
#
#  index_testimonials_on_author_id       (author_id)
#  index_testimonials_on_receiver_id     (receiver_id)
#  index_testimonials_on_transaction_id  (transaction_id)
#

class Testimonial < ApplicationRecord

  belongs_to :author, :class_name => "Person"
  belongs_to :receiver, :class_name => "Person"
  belongs_to :tx, class_name: "Transaction", foreign_key: "transaction_id"

  validates_inclusion_of :grade, :in => 0..1, :allow_nil => false

  scope :positive, -> { where("grade >= 0.5") }
  scope :negative, -> { where("grade < 0.5") }
  scope :id_order, -> { order("id DESC") }
  scope :non_blocked, -> { where(blocked: false) }
  scope :by_community, -> (community) {
    joins(:tx).merge(Transaction.by_community(community.id).exist)
  }

  # Formats grade so that it can be displayed in the UI
  def displayed_grade
    (grade * 4 + 1).to_i
  end

  def positive?
    grade >= 0.5
  end
end
