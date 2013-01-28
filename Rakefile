task :test_email do
  require "yaml"
  $LOAD_PATH << "lib"
  require "air_man"
  m = AirMan::Mailer.new(YAML.load_file("config/config.yml")["development"])
  m.send :send_email, ENV.fetch("TO"), :subject => "test", :body => "test test"
end
