class PopulateListingUnitKind < ActiveRecord::Migration
  class ListingUnit < ActiveRecord::Base
  end

  def up
    ListingUnit.update_all(kind: :time)
  end

  def down
    # noop
  end
end
