class Autoship < ActiveRecord::Base
  has_many :autoship_items, :dependent => :destroy
  has_many :autoship_payments, :dependent => :destroy
  belongs_to :ship_address
  belongs_to :bill_address

  validates :active_date, :start_date, :shipping_method_id, :state, :presence => true

  accepts_nested_attributes_for :autoship_items, :allow_destroy => true, :reject_if => proc { |attributes| attributes['quantity'].blank? || attributes['quantity'].to_i == 0 }
  accepts_nested_attributes_for :ship_address, :allow_destroy => true
  accepts_nested_attributes_for :bill_address, :allow_destroy => true

  def add_payment!(creditcard_id)
    error = nil
    ActiveRecord::Base.transaction do
      begin
        self.autoship_payments.update_all(active: false)
        autoship_payment = AutoshipPayment.new
        autoship_payment.autoship_id = self.id
        autoship_payment.user_id = self.user_id
        autoship_payment.creditcard_id = creditcard_id
        autoship_payment.save!
      rescue => error
        raise ActiveRecord::Rollback
      end
    end
    raise error if error
  end
end
