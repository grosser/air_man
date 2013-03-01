module AirMan
  autoload :Mailer, "air_man/mailer"
  autoload :Reporter, "air_man/reporter"
  autoload :Flowdock, "air_man/flowdock"

  # configure self from env or config.yml
  def self.config
    config = if encoded = ENV['CONFIG_YML']
      require 'base64'
      Base64.decode64(encoded)
    else
      File.read('config.yml')
    end
    YAML.load(config)[env].freeze
  end

  def self.env
    ENV['RAILS_ENV'] || 'development'
  end
end
