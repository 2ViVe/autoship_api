class State < ActiveRecord::Base
  belongs_to  :country
  validates :country, :name, :presence => true

  scope :active, -> { where(active: true) }
end

