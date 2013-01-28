require "airbrake_tools"

class AirMan
  MIN_FREQUENCY = 100
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def report
    data.each do |error, notices, frequency|
      next if frequency < 100
      assignee = config.fetch(:emails).sample
      puts "Assigning #{error.id} to #{assignee}"
      Mailer.new(config).notify(assignee, error, notices, frequency)
    end
  end

  private

  def data
    AirbrakeAPI.account = config.fetch(:subdomain)
    AirbrakeAPI.auth_token = config.fetch(:auth_token)
    AirbrakeAPI.secure = true
    AirbrakeTools.send(:hot, :env => "production", :pages => 1)
  end

  require "net/smtp"
  class Mailer
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def notify(email, error, notices, frequency)
      subject = "AirMan: #{frequency}/hour #{error.error_class} -- #{error.error_message} first: #{error.created_at}"
      body = "https://#{config[:subdomain]}.airbrake.io/groups/#{error.id}"
      send_email(email, :subject => subject, :body => body)
    end

    def send_email(to, opts={})
      email = config.fetch(:mailer)
      message = <<-MESSAGE.gsub(/^\s+/, "")
        From: #{email.fetch(:from_alias, "AirMan")} <#{email.fetch(:username)}>
        To: <#{to}>
        Subject: #{opts.fetch(:subject)}

        #{opts.fetch(:body)}
      MESSAGE

      smtp = Net::SMTP.new "smtp.gmail.com", 587
      smtp.enable_starttls
      smtp.start("gmail.com", email.fetch(:username), email.fetch(:password), :login) do |smtp|
        smtp.send_message message, email.fetch(:username), to
      end
    end
  end
end
