require "spec_helper"

describe AirMan::Reporter do
  class Store < Hash
    alias_method :get, :[]
    alias_method :set, :[]=
  end

  describe "#report" do
    let(:error){ Hashie::Mash.new(:id => 12345) }
    let(:notices){ [Hashie::Mash.new] }
    let(:frequency){ 1000 }
    let(:store){ Store.new }
    let(:config){ YAML.load_file("config/config.yml").fetch("test").merge(:store => store) }

    before do
      AirbrakeTools.should_receive(:hot).and_return [[error, notices, frequency]]
      AirMan::Reporter.any_instance.stub(:puts)
    end

    it "sends out emails for new errors" do
      AirMan::Mailer.any_instance.should_receive(:send_email).with(config[:emails].first, anything)
      AirMan::Reporter.new(config).report
    end

    it "does not send out emails for old errors" do
      AirMan::Mailer.any_instance.should_not_receive(:send_email)
      store.set "air_man.errors.#{error.id}", {}
      AirMan::Reporter.new(config).report
    end
  end
end
