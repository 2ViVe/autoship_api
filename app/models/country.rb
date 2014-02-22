class Country < ActiveRecord::Base
  has_many :states
  validates :name, :iso_name, :presence => true

  scope :all_clientactive, -> { where(is_clientactive: true).order('countries.name ASC') }
end
