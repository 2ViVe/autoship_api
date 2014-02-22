require 'digest/sha1'
class Creditcard < ActiveRecord::Base
  include Concerns::CreditcardToken
  attr_accessor :number, :verification_value

  validates :month, :year, :numericality => { :only_integer => true }, :if => Proc.new { |a| a.token.nil? }
  validates :number, :presence => true, :unless => :has_payment_profile?, :on => :create, :if => Proc.new { |a| a.token.nil? }
  validates :verification_value, :presence => true, :unless => :has_payment_profile?, :on => :create, :if => Proc.new { |a| a.token.nil? }

  def has_payment_profile?
    gateway_customer_profile_id.present?
  end

  # options
  #   token
  #   month
  #   year
  #   number
  #   token_id
  #   cvv
  def self.save_token(options = {})
    creditcard = Creditcard.new(options.slice(:token_id, :month, :year, :number))
    creditcard.set_encrypted_token(options[:token])
    creditcard.issue_number = creditcard.get_encrypted_issue_number("-", options[:cvv])
    creditcard.set_last_digits
    creditcard.save!(:validate => false)
    creditcard
  end

  def get_encrypted_issue_number(number, verification_value)
    get_encrypted_number_and_verification_value(number, verification_value)
  end
  
  def set_encrypted_token(token)
    self.token = get_encrypted_token(token.to_s)
  end

  def set_last_digits
    number.to_s.gsub!(/\s/,'') unless number.nil?
    verification_value.to_s.gsub!(/\s/,'') unless number.nil?
    self.last_digits ||= number.to_s.length <= 4 ? number : number.to_s[0,4] + '****' + number.to_s[-4..-1]
  end
end
