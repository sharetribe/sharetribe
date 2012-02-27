class CreatePollAnswers < ActiveRecord::Migration
  def self.up
    create_table :poll_answers do |t|
      t.integer :poll_id
      t.integer :poll_option_id
      t.string :answerer_id
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :poll_answers
  end
end
