class User < ActiveRecord::Base
  has_many :autoships, dependent: :destroy

  def autoships_limit_reached?
    autoships.complete.count >= 2
  end
end

