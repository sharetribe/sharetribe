class RemoveAdditionalTransactionTypes < ActiveRecord::Migration
  def up
    Service.find_each do |service_trans_type|
      categories = service_trans_type.categories
      categories.each do |category|
    
        # If contains any other trans types than service or request, there's no need for service
        category.transaction_types.each do |tt|
          if tt.class != Request && tt.class != Service
            puts "Removing trans_type Service from category #{category.name} at #{service_trans_type.community.domain}"
            CategoryTransactionType.find_by_category_id_and_transaction_type_id(category.id,service_trans_type.id).destroy
            break
          end
        end
      end
    end
  end

  def down
    raise  ActiveRecord::IrreversibleMigration, "Reverse migration not implemented"
  end
end
