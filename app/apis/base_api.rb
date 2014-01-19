class BaseAPI < Grape::API
  Grape::Middleware::Error.send :include, ResponseHelper

  def self.inherited(subclass)
    super
    subclass.instance_eval do
      format :json
      helpers ResponseHelper

      if current_helper = "#{subclass.name.split('::').last}Helper".safe_constantize
        helpers current_helper
      end

      if current_verson_helper = "#{subclass.name}Helper".safe_constantize
        helpers current_verson_helper
      end

      before do
        ActiveRecord::Base.connection_pool.connections.map(&:verify!)
        I18n.locale = params[:locale].to_sym if params[:locale].present?
      end

      after do
        ActiveRecord::Base.clear_active_connections!
      end

      params do
        optional :locale,  type: String,  desc: 'I18n locale'
      end

      rescue_from ActiveRecord::RecordNotFound do |error|
        generate_error_response(error, 404)
      end

      rescue_from Grape::Exceptions::ValidationErrors, I18n::InvalidLocale, ActiveRecord::RecordInvalid do |error|
        generate_error_response(error, 400)
      end

      rescue_from :all do |error|
        generate_error_response(error, 500)
      end
    end
  end
end
