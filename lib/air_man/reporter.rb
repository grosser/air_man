require "airbrake_tools"
require "dalli"

module AirMan
  class Reporter
    TTL = 2 * 7 * 24 * 60 * 60 # 2 weeks
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def report
      data.each do |error, notices, frequency|
        next if frequency < config.fetch(:frequency)

        store_key = "air_man.errors.#{error.id}"
        if store.get(store_key)
          puts "#{error.id} already assigned"
          next
        end

        assignee = random_assignee
        puts "Assigning #{error.id} to #{assignee}"
        Mailer.new(config).notify(assignee, error, notices, frequency)
        store.set(store_key, :assignee => assignee, :time => Time.now)
      end
    end

    private

    def random_assignee
      config.fetch(:emails).sample
    end

    def store
      @store ||= begin
        support_memcachier
        (config[:store] || Dalli::Client.new(nil, :expires_in => TTL))
      end
    end

    def support_memcachier
      ENV["MEMCACHE_SERVERS"] = ENV["MEMCACHIER_SERVERS"] if ENV["MEMCACHIER_SERVERS"]
      ENV["MEMCACHE_USERNAME"] = ENV["MEMCACHIER_USERNAME"] if ENV["MEMCACHIER_USERNAME"]
      ENV["MEMCACHE_PASSWORD"] = ENV["MEMCACHIER_PASSWORD"] if ENV["MEMCACHIER_PASSWORD"]
    end

    def data
      AirbrakeAPI.account = config.fetch(:subdomain)
      AirbrakeAPI.auth_token = config.fetch(:auth_token)
      AirbrakeAPI.secure = true
      AirbrakeTools.send(:hot, :env => "production", :pages => 1)
    end
  end
end
