module AirMan
  autoload :Mailer, "air_man/mailer"
  autoload :Reporter, "air_man/reporter"

  # configure self from env or config/config.yml
  def self.config
    env = (ENV['RAILS_ENV'] || 'development')
    config = if encoded = ENV['CONFIG_YML']
      require 'base64'
      Base64.decode64(encoded)
    else
      File.read('config/config.yml')
    end
    YAML.load(config)[env].freeze
  end
end
