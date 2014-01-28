class CategoryTranslation < ActiveRecord::Base
  
  attr_accessible :name, :locale, :description

  belongs_to :category
    
end
