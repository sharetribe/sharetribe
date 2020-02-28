class CreateCommunityDomainCheckers < ActiveRecord::Migration[5.2]
  def change
    create_table :community_domain_checkers do |t|
      t.references :community
      t.string :domain
      t.string :state, default: 'initial'

      t.timestamps
    end
  end
end
