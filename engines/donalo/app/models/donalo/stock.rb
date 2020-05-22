module Donalo
  class Stock < ApplicationRecord
    belongs_to :listing
  end
end
