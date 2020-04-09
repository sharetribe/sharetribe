class AddStylesheetNeedsRecompileToCommunity < ActiveRecord::Migration[5.2]
def change
    add_column :communities, :stylesheet_needs_recompile, :boolean, :default => 0, :after => :stylesheet_url
  end
end
