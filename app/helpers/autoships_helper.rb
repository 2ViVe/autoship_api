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

  def should_at_least_select_one_product(autoship_items_attributes)
    autoship_items_attributes.collect { |_, v| v[:quantity].to_i }.sum > 0
  end
end
