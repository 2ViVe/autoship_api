database_config = YAML.load(ERB.new(File.read("#{Goliath.root}/config/database.yml")).result)[Goliath.env.to_s]
ActiveRecord::Base.establish_connection(database_config)
ActiveRecord::Base.default_timezone = :utc
