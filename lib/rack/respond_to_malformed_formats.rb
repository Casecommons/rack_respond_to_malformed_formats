require "rack/mime"
require "json"
require "nokogiri"
require "yaml"

module Rack
  class RespondToMalformedFormats
    VERSION = "0.0.2"

    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      if malformed_response = respond_to_malformed_parameters(env)
        input = env["rack.input"]
        input.rewind
        logger = env["rack.logger"]
        logger.error "Error occurred while parsing request.\nInput:\n\n#{input.read}" if logger
        malformed_response
      else
        @app.call(env)
      end
    end

    private

    def respond_to_malformed_parameters(env)
      request = Request.new(env)

      case (env["HTTP_X_POST_DATA_FORMAT"] || request.content_type).to_s.downcase
      when /xml/
        parse_xml(request.body.read).tap { request.body.rewind }
      when /yaml/
        parse_yaml(request.body.read).tap { request.body.rewind }
      when /json/
        parse_json(request.body.read).tap { request.body.rewind }
      else
        false
      end
    end

    def parse_json(body)
      return false if body.nil? || body.to_s.empty?
      JSON.parse(body)
      false
    rescue JSON::ParserError => e
      [400, {"Content-Type" => "application/json"}, [{:error => e.to_s}.to_json]]
    end

    def parse_xml(body)
      Nokogiri::XML(body) { |config| config.strict }
      false
    rescue Nokogiri::XML::SyntaxError => e
      response = Nokogiri::XML::Builder.new do
        error e.to_s
      end

      [400, {"Content-Type" => "application/xml"}, [response.to_xml]]
    end

    def parse_yaml(body)
      YAML.load(body)
      false
    rescue ArgumentError => e
      [400, {"Content-Type"=> "application/x-yaml"}, [e.to_s]]
    end
  end
end
