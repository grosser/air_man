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
    let(:config){ YAML.load_file(Bundler.root.join("config.yml")).fetch("test").merge(:store => store) }
    let(:hot_response){ [[error, notices, frequency]] }
    let(:report){ AirMan::Reporter.new(config).report }

    before do
      AirbrakeTools.should_receive(:hot).and_return hot_response
      AirbrakeTools.stub(:summary).with{ puts "SUMMARY"; true }
      AirMan::Reporter.any_instance.stub(:puts)
      AirMan::Mailer # load Net::SMTP
      Net::SMTP.any_instance.stub(:do_start) # do not start sessions
      Net::SMTP.any_instance.stub(:send_message) # do not try to send emails
    end

    it "sends out emails for new errors" do
      AirMan::Mailer.any_instance.should_receive(:send_email).with(config[:emails].first, anything)
      report
    end

    it "sends out emails to cc's for new errors" do
      config[:ccs] = ["xxx@yyy.com"]
      AirMan::Mailer.any_instance.should_receive(:send_email).with(config[:emails].first, hash_including(:ccs => ["xxx@yyy.com"]))
      report
    end

    it "does not send out emails for old errors" do
      AirMan::Mailer.any_instance.should_not_receive(:send_email)
      store.set "air_man.errors.#{error.id}", {}
      report
    end

    context "with multiple errors" do
      before do
        error2 = error.dup
        error2.id = 23456
        hot_response << [error2, notices, frequency]
      end

      it "does not auth more than once" do
        Net::SMTP.any_instance.should_receive(:do_start).once
        Net::SMTP.any_instance.should_receive(:send_message).twice
        report
      end
    end
  end
end
