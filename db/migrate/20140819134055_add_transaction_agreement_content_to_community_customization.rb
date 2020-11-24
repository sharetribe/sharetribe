class AddTransactionAgreementContentToCommunityCustomization < ActiveRecord::Migration
  def change
    # MySQL MEDIUMTEXT limit is 16.megabytes - 1 = 16777215
    # http://stackoverflow.com/questions/4443477/rails-3-migration-with-longtext
    add_column :community_customizations, :transaction_agreement_content, :text, :limit => 16777215
  end
end
