require "net/smtp"

module AirMan
  class Mailer
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def notify(email, error, notices, frequency)
      subject = "AirMan: #{frequency}/hour #{error.error_class} -- #{error.error_message} first: #{error.created_at}"
      body = "Details at\nhttps://#{config[:subdomain]}.airbrake.io/groups/#{error.id}" # FYI: single line bodies with urls are ignored by gmail
      send_email(email, :subject => subject, :body => body)
    end

    private

    def send_email(to, options={})
      email = config.fetch(:mailer)
      message = <<-MESSAGE.gsub(/^\s+/, "")
        From: #{email.fetch(:from_alias, "AirMan")} <#{email.fetch(:username)}>
        To: <#{to}>
        Subject: #{options.fetch(:subject)}

        #{options.fetch(:body)}
      MESSAGE

      smtp = Net::SMTP.new "smtp.gmail.com", 587
      smtp.enable_starttls
      smtp.start("gmail.com", email.fetch(:username), email.fetch(:password), :login) do |smtp|
        smtp.send_message message, email.fetch(:username), to
      end
    end
  end
end
