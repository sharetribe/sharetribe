class AddTransactionAgreementLabelToCommunityCustomization < ActiveRecord::Migration
  def change
    add_column :community_customizations, :transaction_agreement_label, :string
  end
end
