class CategoryTranslation < ActiveRecord::Base
  
  attr_accessible :name, :locale, :description

  belongs_to :category
  
  validates_presence_of :category
  validates_presence_of :locale    
end
