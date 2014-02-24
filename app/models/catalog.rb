class Catalog < ActiveRecord::Base
  has_many :catelog_products

  scope :autoship, -> { find_by!(name: 'Autoship') }
end
