require "airbrake_tools"
require "dalli"

module AirMan
  class Reporter
    MIN_FREQUENCY = 100
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def report
      data.each do |error, notices, frequency|
        next if frequency < 100

        store_key = "air_man.errors.#{error.id}"
        next if old = store.get(store_key)

        assignee = config.fetch(:emails).sample
        puts "Assigning #{error.id} to #{assignee}"
        Mailer.new(config).notify(assignee, error, notices, frequency)
        store.set(store_key, :assignee => assignee, :time => Time.now)
      end
    end

    private

    def store
      @store ||= (config[:store] || Dalli::Client.new)
    end

    def data
      AirbrakeAPI.account = config.fetch(:subdomain)
      AirbrakeAPI.auth_token = config.fetch(:auth_token)
      AirbrakeAPI.secure = true
      AirbrakeTools.send(:hot, :env => "production", :pages => 1)
    end
  end
end
