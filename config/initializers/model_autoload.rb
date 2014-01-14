# Load all models to memory every time they are changed to avoid issue in caching.
# See http://aaronvb.com/articles/37-rails-caching-and-undefined-class-module
# if Rails.env == "development"
#   
#   # Handle models not in folders
#   Dir.foreach("#{Rails.root}/app/models") do |model_name|
#     unless [".", "..", "custom_fields", "mercury", "payment_gateways"].include?(model_name)
#       require_dependency model_name
#     end
#   end
#   
#   #Handle models in folders
#   ["custom_fields", "mercury", "payment_gateways"].each do |folder_name|
#     Dir.foreach("#{Rails.root}/app/models/#{folder_name}") do |model_name|
#       unless [".", ".."].include?(model_name)
#         require_dependency model_name
#       end
#     end
#   end
#   
# end

if Rails.env == "development"
  Dir.foreach("#{Rails.root}/app/models") do |model_name|
    require_dependency model_name unless model_name == "." || model_name == ".." || model_name == "custom_fields" || model_name == "mercury" || model_name == "payment_gateways"
  end 
end