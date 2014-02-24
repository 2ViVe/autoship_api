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

  def generate_address_attributes(attributes)
    {
      firstname:  attributes['first-name'],
      middleabbr: attributes['m'],
      lastname:   attributes['last-name'],
      address1:   attributes['street'],
      address2:   attributes['street-cont'],
      city:       attributes['city'],
      state_id:   attributes['state-id'],
      zipcode:    attributes['zip'],
      country_id: attributes['country-id'],
      phone:      attributes['phone']
    }
  end

  def decorate_address_attributes(address)
    {
      'first-name'  => address.firstname,
      'm'           => address.middleabbr,
      'last-name'   => address.lastname,
      'street'      => address.address1,
      'street-cont' => address.address2,
      'city'        => address.city,
      'state-id'    => address.state_id,
      'zip'         => address.zipcode,
      'country-id'  => address.country_id,
      'phone'       => address.phone
    }
  end
end
