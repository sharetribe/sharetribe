class AddDefaultGradeToExistingPersonComments < ActiveRecord::Migration
  def self.up
    PersonComment.all.each do |comment|
      unless comment.grade
        comment.update_attribute(:grade, 0.5)
      end  
    end  
  end

  def self.down
  end
end
