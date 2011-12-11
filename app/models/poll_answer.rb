class PollAnswer < ActiveRecord::Base

  belongs_to :answerer, :class_name => "Person", :foreign_key => "answerer_id", :dependent => :destroy
  belongs_to :poll, :dependent => :destroy

end
