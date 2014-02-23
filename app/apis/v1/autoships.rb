module V1
  class Autoships < ::BaseAPI
    class TokenFailedError < StandardError; end
    class NoProductError < StandardError; end
    class InvalidAutoshipError < StandardError; end
    class InvalidAddressError < StandardError; end
    version 'v1', using: :path

    params do
      requires :user_id, type: Integer, desc: 'User ID'
    end
    resource 'users/:user_id' do
      before do
        @user = User.find(params[:user_id])
      end

      resource 'autoships' do
        desc 'GET /v1/users/:user_id/autoships'
        get do
          generate_success_response autoships: @user.autoships.order("created_at desc")
        end

        desc 'GET /v1/users/:user_id/autoships/:id'
        params do
          requires :id, type: Integer, desc: 'autoship id'
        end
        get ':id' do
          generate_success_response autoship: @user.autoships.find(params[:id])
        end

        desc 'POST /v1/users/:user_id/autoships'
        params do
          requires 'payment-method-id',  type: Integer
          requires 'start-date',         type: Date
          requires 'autoship-date',      type: Integer
          requires 'role-id',            type: Integer
          requires 'status',             type: String, values: ['active', 'inactive']
          requires 'shipping-method-id', type: Integer
          requires 'autoship-items',     type: String  # json

          requires 'creditcard' do
            requires 'number',           type: String, regexp: /\A\d+\z/
            requires 'expiration-year',  type: Integer
            requires 'expiration-month', type: Integer
            requires 'cvv',              type: Integer
          end

          requires 'shipping-address' do
            requires 'first-name',       type: String
            optional 'm',                type: String
            requires 'last-name',        type: String
            requires 'street',           type: String
            optional 'street-cont',      type: String
            requires 'city',             type: String
            requires 'state-id',         type: Integer
            requires 'zip',              type: String
            requires 'country-id',       type: Integer
            requires 'phone',            type: String
          end

          requires 'billing-address' do
            requires 'first-name',       type: String
            optional 'm',                type: String
            requires 'last-name',        type: String
            requires 'street',           type: String
            optional 'street-cont',      type: String
            requires 'city',             type: String
            requires 'state-id',         type: Integer
            requires 'zip',              type: String
            requires 'country-id',       type: Integer
            requires 'phone',            type: String
          end
        end
        post do
          current_user = User.find(headers['X-User-Id'])

          %w(billing shipping).each do |type|
            validate_response = API::Address.validate(type, params["#{type}-address"])
            if !validate_response.success?
              generate_error_response(InvalidAddressError.new(validate_response.error_message), 400) and return
            elsif validate_response.body['failures'].present?
              generate_error_response(InvalidAddressError.new(validate_response.body['failures'].to_json), 400) and return
            end
          end

          autoship_items_attributes = JSON.load(params['autoship-items']).map { |h| { variant_id: h['variant-id'], quantity: h['quantity'] } }
          autoship_items_attributes.select! { |item| item[:quantity].to_i > 0 }
          if autoship_items_attributes.blank?
            generate_error_response(NoProductError.new(I18n.t("please_at_least_select_one_product")), 400) and return
          end

          autoship = Autoship.new({
            user_id: @user.id,
            role_id: params['role-id'],
            start_date: params['start-date'],
            active_date: params['autoship-date'],
            shipping_method_id: params['shipping-method-id'],
            state: params[:status],
            created_by: current_user.id,
            updated_by: current_user.id,
            ship_address_attributes: {
              firstname:  params['shipping-address']['first-name'],
              middleabbr: params['shipping-address']['m'],
              lastname:   params['shipping-address']['last-name'],
              address1:   params['shipping-address']['street'],
              address2:   params['shipping-address']['street-cont'],
              city:       params['shipping-address']['city'],
              state_id:   params['shipping-address']['state-id'],
              zipcode:    params['shipping-address']['zip'],
              country_id: params['shipping-address']['country-id'],
              phone:      params['shipping-address']['phone']
            },
            bill_address_attributes: {
              firstname:  params['billing-address']['first-name'],
              middleabbr: params['billing-address']['m'],
              lastname:   params['billing-address']['last-name'],
              address1:   params['billing-address']['street'],
              address2:   params['billing-address']['street-cont'],
              city:       params['billing-address']['city'],
              state_id:   params['billing-address']['state-id'],
              zipcode:    params['billing-address']['zip'],
              country_id: params['billing-address']['country-id'],
              phone:      params['billing-address']['phone']
            },
            autoship_items_attributes: autoship_items_attributes
          })

          state   = State.find(autoship.bill_address.state_id)
          country = Country.find(autoship.bill_address.country_id)
          token_params = params.slice('payment-method-id', 'creditcard', 'billing-address').merge('user-id' => params[:user_id])
          token_params['billing-address']['state-abbr'] = state.abbr
          token_params['billing-address']['country-iso'] = country.iso
          token_response = API::Payment.create_token(token_params)
          unless token_response.success?
            generate_error_response(TokenFailedError.new(token_response.message), 400) and return
          end

          autoship.autoship_payments.build({
            user_id: @user.id,
            creditcard_attributes: {
              token:  token_response.body['payment-token-id'],
              month:  params[:creditcard]['expiration-month'],
              year:   params[:creditcard]['expiration-year'],
              number: params[:creditcard][:number],
              cvv:    params[:creditcard][:cvv]
            }
          })

          if autoship.save
            generate_success_response('autoship-id' => autoship.id, 'state' => autoship.state)
          else
            generate_error_response(InvalidAutoshipError.new(autoship.errors.full_messages.join('; ')), 400)
          end
        end

        desc 'PUT /v1/users/:user_id/autoships/:id'
        params do
          requires 'payment-method-id',  type: Integer
          requires 'start-date',         type: Date
          requires 'autoship-date',      type: Integer
          requires 'role-id',            type: Integer
          requires 'status',             type: String, values: ['active', 'inactive']
          requires 'shipping-method-id', type: Integer
          requires 'autoship-items',     type: String  # json

          requires 'creditcard' do
            requires 'number',           type: String, regexp: /\A\d+\z/
            requires 'expiration-year',  type: Integer
            requires 'expiration-month', type: Integer
            requires 'cvv',              type: Integer
          end

          requires 'shipping-address' do
            requires 'first-name',       type: String
            optional 'm',                type: String
            requires 'last-name',        type: String
            requires 'street',           type: String
            optional 'street-cont',      type: String
            requires 'city',             type: String
            requires 'state-id',         type: Integer
            requires 'zip',              type: String
            requires 'country-id',       type: Integer
            requires 'phone',            type: String
          end

          requires 'billing-address' do
            requires 'first-name',       type: String
            optional 'm',                type: String
            requires 'last-name',        type: String
            requires 'street',           type: String
            optional 'street-cont',      type: String
            requires 'city',             type: String
            requires 'state-id',         type: Integer
            requires 'zip',              type: String
            requires 'country-id',       type: Integer
            requires 'phone',            type: String
          end
        end
        put ':id' do
          current_user = User.find(headers['X-User-Id'])
          autoship     = @user.autoships.find(params[:id])
          autoship.updated_by = current_user.id

          autoship.ship_address.attributes = {
            firstname:  params['shipping-address']['first-name'],
            middleabbr: params['shipping-address']['m'],
            lastname:   params['shipping-address']['last-name'],
            address1:   params['shipping-address']['street'],
            address2:   params['shipping-address']['street-cont'],
            city:       params['shipping-address']['city'],
            state_id:   params['shipping-address']['state-id'],
            zipcode:    params['shipping-address']['zip'],
            country_id: params['shipping-address']['country-id'],
            phone:      params['shipping-address']['phone']
          }

          autoship.bill_address.attributes = {
            firstname:  params['billing-address']['first-name'],
            middleabbr: params['billing-address']['m'],
            lastname:   params['billing-address']['last-name'],
            address1:   params['billing-address']['street'],
            address2:   params['billing-address']['street-cont'],
            city:       params['billing-address']['city'],
            state_id:   params['billing-address']['state-id'],
            zipcode:    params['billing-address']['zip'],
            country_id: params['billing-address']['country-id'],
            phone:      params['billing-address']['phone']
          }
          validate_address_types = []
          validate_address_types << 'billing' if autoship.bill_address.changed?
          validate_address_types << 'shipping' if autoship.ship_address.changed?
          validate_address_types.each do |type|
            validate_response = API::Address.validate(type, params["#{type}-address"])
            if !validate_response.success?
              generate_error_response(InvalidAddressError.new(validate_response.error_message), 400) and return
            elsif validate_response.body['failures'].present?
              generate_error_response(InvalidAddressError.new(validate_response.body['failures'].to_json), 400) and return
            end
          end

          autoship_items_attributes = JSON.load(params['autoship-items']).map { |h| { variant_id: h['variant-id'], quantity: h['quantity'] } }
          autoship_items_attributes.select! { |item| item[:quantity].to_i > 0 }
          if autoship_items_attributes.blank?
            generate_error_response(NoProductError.new(I18n.t("please_at_least_select_one_product")), 400) and return
          end

          autoship_items  = autoship.autoship_items
          old_variant_ids = autoship_items.map(&:variant_id)
          new_variant_ids = autoship_items_attributes.map { |item| item[:variant_id].to_i }
          old_items_hash  = autoship_items.inject({}) do |result, item|
             result[item.variant_id] = item; result
          end
          new_items_hash  = autoship_items_attributes.inject({}) do |result, item|
            result[item[:variant_id]] = item; result
          end
          autoship_items_attributes = (old_variant_ids - new_variant_ids).map do |variant_id|
            { id: old_items_hash[variant_id].id, variant_id: variant_id, quantity: old_items_hash[variant_id].quantity, _destroy: '1' }
          end
          (old_variant_ids & new_variant_ids).each do |variant_id|
            autoship_items_attributes << new_items_hash[variant_id].merge(id: old_items_hash[variant_id].id)
          end
          autoship.attributes = { autoship_items_attributes: autoship_items_attributes }

          active_payment = autoship.autoship_payments.active_payment
          creditcard     = active_payment.creditcard
          creditcard.attributes = {
            month:  params[:creditcard]['expiration-month'].to_s,
            year:   params[:creditcard]['expiration-year'].to_s,
            number: params[:creditcard][:number],
            cvv:    params[:creditcard][:cvv]
          }
          creditcard.set_attributes

          if creditcard.changed?
            state   = State.find(autoship.bill_address.state_id)
            country = Country.find(autoship.bill_address.country_id)
            token_params = params.slice('payment-method-id', 'creditcard', 'billing-address').merge('user-id' => params[:user_id])
            token_params['billing-address']['state-abbr'] = state.abbr
            token_params['billing-address']['country-iso'] = country.iso
            token_response = API::Payment.create_token(token_params)
            unless token_response.success?
              generate_error_response(TokenFailedError.new(token_response.message), 400) and return
            end

            autoship.autoship_payments.build({
              user_id: @user.id,
              creditcard_attributes: {
                token:  token_response.body['payment-token-id'],
                month:  params[:creditcard]['expiration-month'],
                year:   params[:creditcard]['expiration-year'],
                number: params[:creditcard][:number],
                cvv:    params[:creditcard][:cvv]
              }
            })
          end

          if autoship.save
            generate_success_response('autoship-id' => autoship.id, 'state' => autoship.state)
          else
            generate_error_response(InvalidAutoshipError.new(autoship.errors.full_messages.join('; ')), 400)
          end
        end

        desc 'PATCH /v1/users/:user_id/autoships/:id/update_status'
        params do
          requires 'status', type: String, values: ['active', 'inactive']
        end
        patch ':id/update_status' do
          current_user = User.find(headers['X-User-Id'])
          autoship     = @user.autoships.find(params[:id])
          autoship.updated_by = current_user.id
          autoship.state = params[:status]

          if autoship.save
            generate_success_response('autoship-id' => autoship.id, 'state' => autoship.state)
          else
            generate_error_response(InvalidAutoshipError.new(autoship.errors.full_messages.join('; ')), 400)
          end
        end
      end
    end
  end
end
