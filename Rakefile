require "base64"

task :default do
  sh "rspec spec"
end

task :test_email do
  require "yaml"
  $LOAD_PATH << "lib"
  require "air_man"
  m = AirMan::Mailer.new(YAML.load_file("config/config.yml")["development"])
  m.send :send_email, ENV.fetch("TO"), :subject => "test", :body => "test test"
end

namespace :heroku do
  task :configure do
    config = Base64.encode64(File.read("config/config.yml")).gsub("\n","")
    sh "heroku config:add CONFIG_YML=#{config}"
  end
end
