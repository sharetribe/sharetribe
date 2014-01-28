class CategoryTranslation < ActiveRecord::Base
  belongs_to :category
  
  validates_presence_of :category
  validates_presence_of :locale    
end
