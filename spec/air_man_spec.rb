require "spec_helper"

describe AirMan do
  let(:config){ YAML.load_file("config/config.yml").fetch("test") }

  describe "#report" do
    it "sends out emails for new errors" do
      error = Hashie::Mash.new
      notices = [Hashie::Mash.new]
      frequency = 1000
      AirbrakeTools.should_receive(:hot).and_return [[error, notices, frequency]]
      AirMan::Mailer.any_instance.should_receive(:send_email).with(config[:emails].first, anything)
      AirMan.new(config).report
    end

    it "does not send out emails for old errors" do

    end
  end
end
