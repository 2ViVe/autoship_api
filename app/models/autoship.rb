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

  def next_autoship_date
    today = Date.today
    if today > start_date && active?
      if today.day < active_date
        today.change(day: active_date)
      else
        today.next_month.change(day: active_date)
      end
    end
  end

  def active?
    state == 'active'
  end

  def price
    variant_ids = self.autoship_items.map(&:variant_id)
    autoship_catelog = Catelog.autoship
    CatelogProductVariant.where(variant_id: variant_ids, catelog_product: { role_id: self.role_id, catelog_id: autoship_catelog.id }).joins(:catelog_product).sum(:price)
  end

  # # 包含了税费和邮费的 price
  # def item_price
  #   self.autoship_items
  # end
end
