# == Schema Information
#
# Table name: testimonials
#
#  id               :integer          not null, primary key
#  grade            :float
#  text             :text
#  author_id        :string(255)
#  participation_id :integer
#  transaction_id   :integer
#  created_at       :datetime
#  updated_at       :datetime
#  receiver_id      :string(255)
#
# Indexes
#
#  index_testimonials_on_author_id       (author_id)
#  index_testimonials_on_receiver_id     (receiver_id)
#  index_testimonials_on_transaction_id  (transaction_id)
#

class Testimonial < ActiveRecord::Base

  GRADES = [
    [ "positive", { :form_value => "5", :db_value => 1, :default => false, :icon => "like" } ],
    [ "negative", { :form_value => "1", :db_value => 0, :default => false, :icon => "dislike" } ]
  ]

  belongs_to :author, :class_name => "Person"
  belongs_to :receiver, :class_name => "Person"
  belongs_to :transaction

  validates_inclusion_of :grade, :in => 0..1, :allow_nil => false

  scope :positive, where("grade >= 0.5")

  # Formats grade so that it can be displayed in the UI
  def displayed_grade
    (grade * 4 + 1).to_i
  end

end
