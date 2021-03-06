require "airbrake_tools"
require "dalli"
require "stringio"

module AirMan
  class Reporter
    TTL = 2 * 7 * 24 * 60 * 60 # 2 weeks
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def report
      Mailer.new(config).session do |mailer|
        hot_errors.each do |error, _, frequency|
          store_key = "air_man.errors.#{error.id}"
          if store.get(store_key)
            puts "#{error.id} already assigned"
            next
          end

          assignee = random_assignee
          puts "Assigning #{error.id} to #{assignee || "nobody"}"
          summary = summary(error.id)

          mailer.notify(assignee, config[:ccs], error, frequency, summary) if assignee
          notify_external_services(error, frequency, summary)

          store.set(store_key, :assignee => assignee, :time => Time.now)
        end
      end
    end

    private

    def notify_external_services(error, frequency, summary)
      if config[:flowdock]
        @flowdock ||= Flowdock.new(config[:flowdock])
        @flowdock.notify(error, frequency, summary)
      end
    end

    def summary(id)
      record_stdout{ AirbrakeTools.summary(id, {}) }
    end

    def record_stdout
      $stdout, old = StringIO.new, $stdout
      yield
      $stdout.string
    ensure
      $stdout = old
    end

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

    def hot_errors
      AirbrakeAPI.account = config.fetch(:subdomain)
      AirbrakeAPI.auth_token = config.fetch(:auth_token)
      AirbrakeAPI.secure = true
      errors = (config[:project_ids] || [nil]).flat_map do |project_id|
        AirbrakeTools.hot(env: "production", pages: 1, project_id: project_id)
      end.select { |_, _, frequency| frequency >= config.fetch(:frequency) }
      puts # errors prints without a newline
      errors
    end
  end
end
