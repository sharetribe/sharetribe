class EnableCatalan < ActiveRecord::Migration[5.2]
  def up
    donalo = Community.first

    # The order of locales matters. The first one is the default
    donalo.locales << 'ca'
    donalo.save!
  end

  def down
    donalo = Community.first
    donalo.update_attribute(:settings, { 'locales' => ['es'] })
  end
end
