require "yaml"
require "base64"

$LOAD_PATH << "lib"
require "air_man"

desc "run tests"
task :default do
  sh "rspec spec"
end

desc "report"
task :report do
  AirMan::Reporter.new(AirMan.config).report
end

namespace :test do
  desc "test email sending"
  task :email do
    m = AirMan::Mailer.new(AirMan.config)
    m.session do
      m.send :send_email, (ENV["TO"] || "test@example.com"), :subject => "test", :body => "test test"
    end
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
