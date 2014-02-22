class AutoshipItem < ActiveRecord::Base
  belongs_to :autoship

  validates :variant_id, :presence => true, :uniqueness => {:scope => :autoship_id}
  validates :quantity, :numericality => {:greater_than => 0, :only_integer => true, :less_than => 999 }
end
