class Variant < ActiveRecord::Base
  belongs_to :product
  has_one :autoship_item
  has_one :variant_commission
end
