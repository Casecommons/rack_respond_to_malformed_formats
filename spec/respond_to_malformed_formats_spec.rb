require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe Rack::RespondToMalformedFormats do
  def wrapped_app(app)
    Rack::Builder.new do
      use Rack::Lint
      use Rack::RespondToMalformedFormats
      use Rack::Lint
      run app
    end
  end

  def response_for_env(env)
    StringIO.new("Got: #{env['rack.input'].read}")
  end

  def read(body)
    "".tap do |body_string|
      body.each do |body_part|
        body_string << body_part
      end
    end
  end

  context "when the format is HTML" do
    it "should do nothing" do
      test_input = '<html></html>'
      app = lambda { |env| [200, {"Content-Type" => "text/html"}, response_for_env(env)] }
      request = Rack::MockRequest.env_for("/", :params => "", "CONTENT_TYPE" => "text/html", :input => test_input)
      body = wrapped_app(app).call(request).last

      read(body).should == 'Got: <html></html>'
    end
  end

  context "when the format is JSON" do
    context "and it is valid" do
      it "should do nothing" do
        test_input = '{"foo":"bar"}'
        app = lambda { |env| [200, {"Content-Type" => "application/json"}, response_for_env(env)] }
        request = Rack::MockRequest.env_for("/", :params => "", "CONTENT_TYPE" => "application/json", :input => test_input)
        body = wrapped_app(app).call(request).last

        read(body).should == 'Got: {"foo":"bar"}'
      end
    end

    context "and it is invalid" do
      it "should return a 400 with a message" do
        test_input = '{"foo":'
        app = lambda { |env| [200, {"Content-Type" => "application/json"}, response_for_env(env)] }
        request = Rack::MockRequest.env_for("/", :params => "", "CONTENT_TYPE" => "application/json", :input => test_input)
        response = wrapped_app(app).call(request)

        response[0].should == 400
        response[1]["Content-Type"].should == "application/json"
        read(response.last).should =~ /.*error.*unexpected token.*/
      end
    end
  end

  context "when the format is XML" do
    context "and it is valid" do
      it "should do nothing" do
        test_input = '<?xml version="1.0"?><foo>bar</foo>'
        app = lambda { |env| [200, {"Content-Type" => "application/xml"}, response_for_env(env)] }
        request = Rack::MockRequest.env_for("/", :params => "", "CONTENT_TYPE" => "application/xml", :input => test_input)
        body = wrapped_app(app).call(request).last

        read(body).should == 'Got: <?xml version="1.0"?><foo>bar</foo>'
      end
    end

    context "and it is invalid" do
      it "should return a 400 with a message" do
        test_input = '<ml><foo>bar'
        app = lambda { |env| [200, {"Content-Type" => "application/xml"}, response_for_env(env)] }
        request = Rack::MockRequest.env_for("/", :params => "", "CONTENT_TYPE" => "application/xml", :input => test_input)
        response = wrapped_app(app).call(request)

        response[0].should == 400
        response[1]["Content-Type"].should == "application/xml"
        read(response.last).should =~ /.*<error>Premature.*<\/error>.*/
      end
    end
  end

  context "when the format is YAML" do
    context "and it is valid" do
      it "should do nothing" do
        test_input = "--- \nfoo: bar\n"
        app = lambda { |env| [200, {"Content-Type" => "application/x-yaml"}, response_for_env(env)] }
        request = Rack::MockRequest.env_for("/", :params => "", "CONTENT_TYPE" => "application/x-yaml", :input => test_input)
        body = wrapped_app(app).call(request).last

        read(body).should == "Got: --- \nfoo: bar\n"
      end
    end

    context "and it is invalid" do
      it "should return a 400 with a message" do
        test_input = "--- what:\nawagasd"
        app = lambda { |env| [200, {"Content-Type" => "application/x-yaml"}, response_for_env(env)] }
        request = Rack::MockRequest.env_for("/", :params => "", "CONTENT_TYPE" => "application/x-yaml", :input => test_input)
        response = wrapped_app(app).call(request)

        response[0].should == 400
        response[1]["Content-Type"].should == "application/x-yaml"
        read(response.last).should =~ /.*syntax error.*/
      end
    end
  end
end
