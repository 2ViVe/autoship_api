class CatalogProductVariant < ActiveRecord::Base
  belongs_to :catalog_product

  def self.allowed_variant_ids(role_id)
    Catalog.autoship
  end
end
