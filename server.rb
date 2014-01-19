require "#{__dir__}/config/boot"
class Application < Goliath::API

  def response(env)
    ::Autoships.call(env)
  end
end
