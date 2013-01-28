require "yaml"
require "base64"

$LOAD_PATH << "lib"
require "air_man"

task :default do
  sh "rspec spec"
end

namespace :test do
  desc "test email sending"
  task :email do
    m = AirMan::Mailer.new(AirMan.config)
    m.send :send_email, (ENV["TO"] || "test@example.com"), :subject => "test", :body => "test test"
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
    config = Base64.encode64(File.read("config/config.yml")).gsub("\n","")
    sh "heroku config:add CONFIG_YML=#{config}"
  end
end
