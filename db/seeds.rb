# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
#  listing_type = valid_st.keys[SecureRandom.random_number(valid_st.keys.length)]

CategoriesHelper.load_default_categories_to_db

# Create default payment gateways to DB
Mangopay.create unless Mangopay.count > 0
Checkout.create unless Checkout.count > 0
