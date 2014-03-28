class Poll < ActiveRecord::Base

  has_many :options, :class_name => "PollOption"
  has_many :answers, :class_name => "PollAnswer"
  belongs_to :author, :class_name => "Person"

  def poll_options=(poll_options)
    options.clear
    poll_options.each { |option| options.build(option) }
  end

  def status
    active? ? "open" : "closed"
  end

  def calculate_percentages
    options.each do |option|
      option.update_attribute(:percentage, (option.answers.size.to_f / answers.size.to_f).round(3)*100)
    end
  end

end
