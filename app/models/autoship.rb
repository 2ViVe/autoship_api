class Autoship < ActiveRecord::Base

  validates :active_date, :presence => true
  validates :start_date, :presence => true
  validates :shipping_method_id, :presence => true, :on => :create
  validates :state, :presence => true, :on => :create

  # after_initialize :init_start_date

  # has_many :autoship_items, :dependent => :destroy
  # has_many :autoship_payments, :dependent => :destroy
  # has_many :variants, :through => :autoship_items
  # has_many :autoship_update_logs, :foreign_key => "id_old", :dependent => :destroy
  # has_many :autoship_item_update_logs, :foreign_key => "autoship_id_old"
  # has_many :autoship_item_delete_logs, :foreign_key => "autoship_id_old"

  # belongs_to :user
  # belongs_to :created_by_user, :class_name => "User", :foreign_key => "created_by"
  # belongs_to :updated_by_user, :class_name => "User", :foreign_key => "updated_by"
  # belongs_to :ship_address, :foreign_key => "ship_address_id", :class_name => "Address"
  # belongs_to :bill_address, :foreign_key => "bill_address_id", :class_name => "Address"
  # belongs_to :shipping_method

  # attr_accessible :active_date, :state, :autoship_items_attributes, :user_id, :shipping_method_id, :start_date, :pickup_location_id
  # attr_accessible :autoship_payments_attributes
  # attr_accessible :ship_address_attributes
  # attr_accessible :bill_address_attributes

  # accepts_nested_attributes_for :autoship_items,  :allow_destroy => true, 
  #   :reject_if => proc { |attributes| attributes['quantity'].blank? || attributes['quantity'].to_i == 0 }
  # accepts_nested_attributes_for :autoship_payments,  :allow_destroy => true
  # accepts_nested_attributes_for :ship_address, :allow_destroy => true
  # accepts_nested_attributes_for :bill_address, :allow_destroy => true

  # before_create :set_complete_status

  # ############################################################
  # def set_complete_status
  #   self.state = 'complete' if self.state.blank?
  # end

  # def self.complete
  #   where(:state => "complete")
  # end

  # def state_for_display
  #   if self.state == "complete"
  #     "active"
  #   else
  #     self.state
  #   end
  # end

  # def pickup_location_id= address_id
  #   if address_id.present? && self.shipping_method && self.shipping_method.name =~ /pick/i
  #     self.ship_address_id = address_id
  #   end
  # end



  # ############################################################
  # def item_total(autoship_items = self.autoship_items)
  #   total = 0
  #   autoship_items.each do |item|
  #     total += item.quantity * item.variant.get_product_price(self.user)
  #   end
  #   total
  # end

  # ############################################################
  # def find_as_orders
  #   self.autoship_items
  # end

  # def has_change_log?
  #   self.change_logs.count > 0 || !self.created_by.blank?
  # end

  # ############################################################
  # def contains?(variant)
  #   self.autoship_items.detect { |item| item.variant_id == variant.id }
  # end

  # ############################################################
  # def additem(as_item)
  #   as_itme.quantity = 1  unless as_item.quantity
  #   self.autoship_items << as_item
  # end

  # ############################################################
  # def additem_by_order(order)
  #   order.line_items.each do |line_item|
  #     unless order.user.autoships.detect {|head| head.contains?(line_item.variant)}
  #       as_item = AutoshipItem.new
  #       as_item.quantity = line_item.quantity
  #       as_item.variant_id = line_item.variant.id
  #       self.autoship_items << as_item
  #     end
  #   end
  # end

  # ############################################################
  # def add_variant(variant, quantity = 1)
  #   current_autoship_item = contains?(variant)
  #   if current_autoship_item
  #     current_autoship_item.quantity = quantity
  #     current_autoship_item.save
  #   else
  #     current_autoship_item = AutoshipItem.new(:quantity => quantity)
  #     current_autoship_item.variant = variant
  #     self.autoship_items << current_autoship_item
  #   end
  # end

  # def total_price
  #   self.autoship_items.where("variant_id is not null").collect{|item| item.quantity * item.variant.wholesale_price}.sum
  # end

  # def qualification_volume
  #   self.autoship_items.where("variant_id is not null").collect{|item| item.quantity * item.variant.qualification_volume}.sum
  # end

  # def commission_volume
  #   self.autoship_items.where("variant_id is not null").collect{|item| item.quantity * item.variant.commission_volume}.sum
  # end


  # ############################################################
  # def change_logs
  #   attrs = %w{state active_date start_date}
  #   conditions = attrs.collect do |attr|
  #     "#{attr}_new <> #{attr}_old or " 
  #   end.join("")

  #   (self.autoship_update_logs.where("#{conditions} updated_by_new is not null") + 
  #    self.autoship_item_update_logs.where("quantity_old <> quantity_new") +
  #    self.autoship_item_delete_logs).sort_by {|log| log.created_at}.reverse
  # end

  # def add_token_payment(creditcard_id, address)
  #   autoship_payment = AutoshipPayment.new
  #   autoship_payment.autoship_id = self.id
  #   autoship_payment.user_id = self.user_id
  #   autoship_payment.creditcard_id = creditcard_id
  #   autoship_payment.save!  

  #   self.autoship_payments.each do |payment|
  #     payment_creditcard = payment.creditcard
  #     if payment_creditcard.id != creditcard_id
  #       payment_creditcard.active = false
  #       payment_creditcard.save!
  #     end
  #   end
  # end

  # def add_payment(payment_params, address)
  #   if (payment_params.nil?) ||
  #     (payment_params[:number].nil?) || 
  #     (payment_params[:verification_value].nil?) ||
  #     (payment_params[:month].nil?) ||
  #     (payment_params[:year].nil?)
  #     return
  #   end

  #   autoship_payment = AutoshipPayment.new
  #   autoship_payment.autoship_id = self.id
  #   autoship_payment.user_id = self.user_id
  #   creditcard = Creditcard.new(payment_params)
  #   creditcard.address_id = address.id
  #   creditcard.issue_number = creditcard.get_encrypted_issue_number(creditcard.number,
  #                                                                   creditcard.verification_value)
  #   creditcard.first_name = address.firstname
  #   creditcard.last_name = address.lastname
  #   creditcard.active = true
  #   creditcard.save!  

  #   autoship_payment.creditcard_id = creditcard.id
  #   autoship_payment.save!  

  #   self.autoship_payments.each do |payment|
  #     payment_creditcard = payment.creditcard
  #     if payment_creditcard.id != creditcard.id
  #       payment_creditcard.active = false
  #       payment_creditcard.save!
  #     end
  #   end
  # end

  # def self.reset_payment_autoships(user_id)
  #   self.joins("LEFT JOIN autoship_payments ON autoships.id = autoship_payments.autoship_id").
  #     joins("LEFT JOIN creditcards ON autoship_payments.creditcard_id = creditcards.id").
  #     where(["autoships.user_id = ? and autoships.state = 'complete' and creditcards.token like '%-%'", user_id]).uniq
  # end

  # def build_address_addon(address_name)
  #   user = self.user
  #   if self.send(address_name).address_addon.blank?
  #     if user.send(address_name).address_addon.present?
  #       address_attrs = user.send(address_name).address_addon.attributes
  #       address_attrs.delete("id")
  #       address_attrs.delete("address_id")
  #       self.send(address_name).build_address_addon(address_attrs)
  #     else
  #       self.send(address_name).build_address_addon
  #     end
  #   end
  # end

  # def build_address_addons
  #   user = self.user
  #   if user.ship_address.country_id == 1100 # Japan
  #     self.build_address_addon("ship_address")
  #     self.build_address_addon("bill_address")
  #   elsif user.ship_address.country_id == 1130 # Mexico, only ship address has address_addon
  #     self.build_address_addon("ship_address")
  #   end
  # end

  # private

  # def init_start_date
  #   if self.new_record? && self.start_date.nil?
  #     if self.user && self.user.country.iso = "JP"
  #       self.active_date = 5
  #       self.start_date =  1.month.from_now.at_beginning_of_month.to_date - 1 + self.active_date
  #       self.start_date = '2013-6-5' if self.start_date < '2013-6-5'.to_date

  #     else
  #       self.active_date = Time.now.day >= 15 ? 15 : 5
  #       self.start_date =  1.month.from_now.at_beginning_of_month.to_date - 1 + self.active_date
  #     end
  #   end
  # end
end

# == Schema Information
#
# Table name: autoships
#
#  id                   :integer         not null, primary key
#  user_id              :integer
#  order_number         :string(255)
#  active_date          :integer
#  state                :string(255)
#  bill_address_id      :integer
#  ship_address_id      :integer
#  shipping_method_id   :integer
#  shipment_state       :string(255)
#  payment_state        :string(255)
#  email                :string(255)
#  special_instructions :text
#  start_date           :date
#  created_by           :integer
#  updated_by           :integer
#  created_at           :datetime
#  updated_at           :datetime
#
