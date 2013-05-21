class AddBadgesInUseAndTestimonialsInUseToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :badges_in_use, :boolean, :default => true
    add_column :communities, :testimonials_in_use, :boolean, :default => true
  end
end
