require "net/smtp"

module AirMan
  class Mailer
    attr_reader :config

    def initialize(config)
      @config = config
    end

    # Google returns 535-5.7.1 on to frequent auth -> only do it once
    def session
      @session = true
      yield self
    ensure
      @session = false
      stop_smtp
    end

    def notify(email, ccs, error, frequency, summary)
      subject = "AirMan: #{frequency}/hour #{error.error_class} -- #{error.error_message} first: #{error.created_at}"
      # FYI: if the first line is a url the email is blank in gmail
      body = "Details at\nhttps://#{config[:subdomain]}.airbrake.io/groups/#{error.id}\n\n#{summary}"
      send_email(email, :ccs => ccs, :subject => subject, :body => body)
    end

    private

    def send_email(to, options={})
      cc = (options[:ccs] ? "CC: #{options[:ccs].join(", ")}" : "")
      message = <<-MESSAGE.gsub(/^\s+/, "")
        From: #{smtp_config.fetch(:from_alias, "AirMan")} <#{smtp_config.fetch(:username)}>
        To: <#{to}>
        Subject: #{options.fetch(:subject)}
        #{cc}

        #{options.fetch(:body)}
      MESSAGE

      smtp.send_message message, smtp_config.fetch(:username), to
    end

    def smtp
      raise unless @session
      @smtp ||= begin
        smtp = Net::SMTP.new "smtp.gmail.com", 587
        smtp.enable_starttls
        smtp.start("gmail.com", smtp_config.fetch(:username), smtp_config.fetch(:password), :login)
        smtp
      end
    end

    def stop_smtp
      @smtp.finish if @smtp && @smtp.started?
    end

    def smtp_config
      config.fetch(:mailer)
    end
  end
end
