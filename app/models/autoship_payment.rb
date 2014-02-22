class AutoshipPayment < ActiveRecord::Base
   belongs_to :autoship
   belongs_to :creditcard
end
