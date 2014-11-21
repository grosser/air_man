require "bundler/setup"
require "yaml"
require "base64"
require "hashie/mash"

$LOAD_PATH << "lib"
require "air_man"

desc "run tests"
task :default do
  sh "rspec spec"
end

desc "report"
task :report do
  report_errors_to_airbrake do
    AirMan::Reporter.new(AirMan.config).report
  end
end

namespace :test do
  desc "test email sending"
  task :email, [:to] do |t,args|
    to = args[:to] || raise("give me the to")
    m = AirMan::Mailer.new(AirMan.config)
    m.session do
      m.send :send_email, to, :subject => "test for AirMan", :body => "test test\nmoretest\neven moree"
    end
  end

  desc "test flowdock"
  task :flowdock do
    error = Mash.new(:created_at => Time.now, :error_class => "Test error", :error_message => "Test error message")
    AirMan::Flowdock.new(AirMan.config[:flowdock]).notify(error, 111.123, "SUMMARY")
  end

  desc "test the memcache store"
  task :store do
    store = AirMan::Reporter.new(AirMan.config).send(:store)
    store.set "xxx", :SUCCESS
    raise unless store.get("xxx") == :SUCCESS
  end
end

namespace :heroku do
  task :configure do
    config = Base64.encode64(File.read("config.yml")).gsub("\n","")
    sh "heroku config:add CONFIG_YML=#{config}"
    sh "heroku config:add RAILS_ENV=production"
  end
end

def report_errors_to_airbrake
  if !["test", "development"].include?(AirMan.env) and api_key = AirMan.config[:report_errors_to]
    require "airbrake"
    Airbrake.configure { |config| config.api_key = api_key }
    begin
      yield
    rescue Exception => e
      puts "reporting error to airbrake"
      Airbrake.notify_or_ignore(e)
      raise e
    end
  else
    yield
  end
end
