require 'redis'
require 'redis/connection/hiredis'

$redis = Redis.new(YAML.load_file("#{Goliath.root}/config/redis.yml").symbolize_keys[:cache])
$i18n_redis = Redis.new(YAML.load_file("#{Goliath.root}/config/redis.yml").symbolize_keys[:i18n])
I18n.backend = I18n::Backend::CachedKeyValueStore.new($i18n_redis)
I18n.enforce_available_locales = true
I18n.default_locale = :'en-US'
