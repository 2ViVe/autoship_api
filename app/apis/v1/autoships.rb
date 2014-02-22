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
    resource 'user/:user_id' do
      before do
        @user = User.find(params[:user_id])
      end

      resource 'autoships' do
        desc 'GET /v1/user/:user_id/autoships'
        get do
          generate_success_response autoships: @user.autoships.order("created_at desc")
        end

        desc 'GET /v1/user/:user_id/autoships/:id'
        params do
          requires :id, type: Integer, desc: 'autoship id'
        end
        get ':id' do
          generate_success_response autoship: @user.autoships.find(params[:id])
        end

        desc 'POST /v1/user/:user_id/autoships'
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
            autoship_items_attributes: JSON.load(params['autoship-items']).map { |h| { variant_id: h['variant-id'], quantity: h['quantity'] } }
          })

          if autoship.autoship_items.inject(0) { |sum, item| sum += item.quantity } <= 0
            generate_error_response(NoProductError.new(I18n.t("please_at_least_select_one_product")), 400) and return
          end

          # state   = State.find(autoship.bill_address.state_id)
          # country = Country.find(autoship.bill_address.country_id)
          # token_params = params.slice('payment-method-id', 'creditcard', 'billing-address').merge('user-id' => params[:user_id])
          # token_params['billing-address']['state-abbr'] = state.abbr
          # token_params['billing-address']['country-iso'] = country.iso
          # token_response = API::Payment.create_token(token_params)
          # unless token_response.success?
          #   generate_error_response(TokenFailedError.new(token_response.message), 400) and return
          # end

          creditcard = Creditcard.save_token({
            token:  'test',#token_response.body['payment-token-id'],
            month:  params[:creditcard]['expiration-month'],
            year:   params[:creditcard]['expiration-year'],
            number: params[:creditcard][:number],
            cvv:    params[:creditcard][:cvv]
          })

          if autoship.save
            autoship.add_payment!(creditcard.id)
            generate_success_response('autoship-id' => autoship.id, 'state' => autoship.state)
          else
            generate_error_response(InvalidAutoshipError.new(autoship.errors.full_messages.join('; ')), 400)
          end
        end
      end
    end
  end
end
