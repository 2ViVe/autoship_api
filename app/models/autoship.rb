class Autoship < ActiveRecord::Base
  has_many :autoship_items, :dependent => :destroy
  has_many :autoship_payments, :dependent => :destroy
  belongs_to :ship_address
  belongs_to :bill_address

  validates :active_date, :start_date, :shipping_method_id, :state, :presence => true

  accepts_nested_attributes_for :autoship_items, :allow_destroy => true, :reject_if => proc { |attributes| attributes['quantity'].blank? || attributes['quantity'].to_i == 0 }
  accepts_nested_attributes_for :ship_address, :allow_destroy => true
  accepts_nested_attributes_for :bill_address, :allow_destroy => true
  accepts_nested_attributes_for :autoship_payments, :allow_destroy => true
end
