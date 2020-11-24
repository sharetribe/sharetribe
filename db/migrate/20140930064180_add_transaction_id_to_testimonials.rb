class AddTransactionIdToTestimonials < ActiveRecord::Migration
  def change
    add_column :testimonials, :transaction_id, :integer, after: :participation_id
  end
end
