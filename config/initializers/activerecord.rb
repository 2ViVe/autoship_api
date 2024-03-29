database_config = YAML.load(ERB.new(File.read("#{Goliath.root}/config/database.yml")).result)[Goliath.env.to_s]
ActiveRecord::Base.establish_connection(database_config)
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.logger = begin
  Dir.mkdir("#{Goliath.root}/log") unless Dir.exists?("#{Goliath.root}/log")
  logger = ActiveSupport::Logger.new("#{Goliath.root}/log/activerecord.log")
  logger.level = Logger::DEBUG
  logger.formatter = proc { |severity, datetime, progname, msg|
    "#{severity} [#{datetime}] #{msg}\n"
  }
  logger
end
