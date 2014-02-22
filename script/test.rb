require 'pp'
require "#{__dir__}/../config/boot"

def request_body
  {
    'payment-method-id' => 3129,
    'start-date' => '2014-09-09',
    'autoship-date' => 15,
    'role-id' => 3,
    'status' => 'active',
    'shipping-method-id' => 1,
    'creditcard' => {
      'number' => '4111111111111111',
      'expiration-year' => '2015',
      'expiration-month' => '09',
      'cvv' => 113
    },
    'shipping-address' => {
      "first-name"=>"firstname",
      "last-name"=>"lllll",
      "street"=>"f-39-m,m floor,block f,the crest,3-two square",
      "street-conf"=>"no. 2,jalan 19/1 | petaling jaya",
      "city"=>"petaling jaya",
      "state-id"=>11341,
      "zip"=>"46300",
      "country-id"=>1122,
      "phone"=>"(603)79608799"
    },
    'billing-address' => {
      "first-name"=>"firstname",
      "last-name"=>"lllll",
      "street"=>"f-39-m,m floor,block f,the crest,3-two square",
      "street-conf"=>"no. 2,jalan 19/1 | petaling jaya",
      "city"=>"petaling jaya",
      "state-id"=>11341,
      "zip"=>"46300",
      "country-id"=>1122,
      "phone"=>"(603)79608799"
    },
    'autoship-items' => "[{\"variant-id\":1,\"quantity\":1},{\"variant-id\":2,\"quantity\":1}]"
  }
end

result = RestClient.post('http://127.0.0.1:3000/v1/user/15391/autoships', request_body, accept: :json, accept_language: 'en-US', x_company_code: 'xxx', x_user_id: 15391) do |response, request|
  API::Response.new response
end

pp "post http://127.0.0.1:3000/v1/user/15391/autoships"
pp "response.success? => #{result.success?}"
pp "response.body => \n#{result.body}"
