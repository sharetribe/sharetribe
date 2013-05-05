class AddServiceLogoStyleToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :service_logo_style, :string, :default => "full-logo"
  end
end
