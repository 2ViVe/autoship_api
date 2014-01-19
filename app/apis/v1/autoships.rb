module V1
  class Autoships < ::BaseAPI
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
        get "/" do
          generate_success_response autoships: @user.autoships.order("created_at desc")
        end

        desc 'GET /v1/user/:user_id/autoships/new'
        get 'new' do
        end
      end
    end
  end
end
