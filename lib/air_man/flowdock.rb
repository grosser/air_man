require "json"
require "rest_client"

module AirMan
  class Flowdock
    URL = "https://api.flowdock.com/v1/messages/team_inbox/"

    def initialize(config)
      @config = config
    end

    def notify(error, frequency, summary)
      subject = "AirMan: #{frequency}/hour #{error.error_class} -- #{error.error_class} first: #{error.created_at}"
      @config.fetch(:tokens).each do |token|
        data = {
          "source" => "AirMan",
          "from_address" => "Air@Man.error",
          "subject" => subject,
          "content" => summary,
          "tags" =>  ["#airbrake"]
        }
        RestClient.post(URL + token, data, :content_type => :json)
      end
    end
  end
end
