class CategoryTranslation < ActiveRecord::Base
  
  attr_accessible :name, :locale, :description

  belongs_to :category, touch: true
  
  validates_presence_of :locale    
end
