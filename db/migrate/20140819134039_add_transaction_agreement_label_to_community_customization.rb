class AddTransactionAgreementLabelToCommunityCustomization < ActiveRecord::Migration[5.2]
def change
    add_column :community_customizations, :transaction_agreement_label, :string
  end
end
