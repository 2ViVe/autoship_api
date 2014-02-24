class CatalogProduct < ActiveRecord::Base
  has_many :catelog_product_variants
end
