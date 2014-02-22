class User < ActiveRecord::Base
  has_many :autoships, dependent: :destroy
end

