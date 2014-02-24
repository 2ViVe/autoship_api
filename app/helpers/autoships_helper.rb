module AutoshipsHelper

  def deep_dasherize_hash(hash = {})
    hash.inject(ActiveSupport::HashWithIndifferentAccess.new) do |result, k_v|
      key, value = *k_v
      result[key.to_s.dasherize] = case value
                                   when Hash
                                     deep_dasherize_hash(value)
                                   when ActiveRecord::Base
                                     deep_dasherize_hash(value.attributes)
                                   else
                                     value
                                   end
      result
    end
  end

  def deep_underscore_hash(hash = {})
    hash.inject(ActiveSupport::HashWithIndifferentAccess.new) do |result, k_v|
      key, value = *k_v
      result[key.to_s.underscore] = case value
                                   when Hash
                                     deep_underscore_hash(value)
                                   when ActiveRecord::Base
                                     deep_underscore_hash(value.attributes)
                                   else
                                     value
                                   end
      result
    end
  end

  def generate_autoship_response(autoship)
    result = {
      'id'                => autoship.id,
      'payment-method-id' => autoship.autoship_payments.active_payment.payment_method_id,
      'start-date'        => autoship.start_date.to_s,
      'autoship-day'      => autoship.active_date,
      'user-id'           => autoship.user_id,
      'role-id'           => autoship.role_id,
      'status'            => autoship.state,
      'shipping-address'  => autoship.ship_address.decorated_attributes,
      'billing-address'   => autoship.bill_address.decorated_attributes
    }

    variants_price_hash = autoship.variants_price_hash
    result['autoship-items'] = autoship.autoship_items.map do |item|
      variant = item.variant
      {
        'variant-id'   => variant.id,
        'sku'          => variant.sku,
        'product-name' => variant.product.name,
        'quantity'     => item.quantity,
        'image-url'    => '',
        'unit-price'   => variants_price_hash[variant.id],
        'unit-pv'      => variant.variant_commission.volume
      }
    end

    result['item-price'] = variants_price_hash.values.sum
    result
  end
end
