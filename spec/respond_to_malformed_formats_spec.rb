require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe Rack::RespondToMalformedFormats do
  context "when the format is HTML" do
    it "should do nothing" do
      test_input = '<html></html>'
      app = lambda { |env| [200, {"CONTEN_TYPE" => "text/html"}, test_input] }
      request = Rack::MockRequest.env_for("/", :params => "", "CONTENT_TYPE" => "test/html", :input => test_input)
      body = Rack::RespondToMalformedFormats.new(app).call(request).last

      body.should == test_input
    end
  end

  context "when the format is JSON" do
    context "and it is valid" do
      it "should do nothing" do
        test_input = '{"foo":"bar"}'
        app = lambda { |env| [200, {"CONTENT_TYPE" => "application/json"}, test_input] }
        request = Rack::MockRequest.env_for("/", :params => "", "CONTENT_TYPE" => "application/json", :input => test_input)
        body = Rack::RespondToMalformedFormats.new(app).call(request).last

        body.should == test_input
      end
    end

    context "and it is invalid" do
      it "should return a 400 with a message" do
        test_input = '{"foo":'
        app = lambda { |env| [200, {"CONTENT_TYPE" => "application/json"}, test_input] }
        request = Rack::MockRequest.env_for("/", :params => "", "CONTENT_TYPE" => "application/json", :input => test_input)
        response = Rack::RespondToMalformedFormats.new(app).call(request)

        response[0].should == 400
        response[1]["Content-Type"].should == "application/json"
        response[2].first.should =~ /.*error.*unexpected token.*/
      end
    end
  end

  context "when the format is XML" do
    context "and it is valid" do
      it "should do nothing" do
        test_input = '<?xml version="1.0"?><foo>bar</foo>'
        app = lambda { |env| [200, {"CONTENT_TYPE" => "application/xml"}, test_input] }
        request = Rack::MockRequest.env_for("/", :params => "", "CONTENT_TYPE" => "application/xml", :input => test_input)
        body = Rack::RespondToMalformedFormats.new(app).call(request).last

        body.should == test_input
      end
    end

    context "and it is invalid" do
      it "should return a 400 with a message" do
        test_input = '<ml><foo>bar'
        app = lambda { |env| [200, {"CONTENT_TYPE" => "application/xml"}, test_input] }
        request = Rack::MockRequest.env_for("/", :params => "", "CONTENT_TYPE" => "application/xml", :input => test_input)
        response = Rack::RespondToMalformedFormats.new(app).call(request)

        response[0].should == 400
        response[1]["Content-Type"].should == "application/xml"
        response[2].first.should =~ /.*<error>Premature.*<\/error>.*/
      end
    end
  end

  context "when the format is YAML" do
    context "and it is valid" do
      it "should do nothing" do
        test_input = "--- \nfoo: bar\n"
        app = lambda { |env| [200, {"CONTENT_TYPE" => "application/x-yaml"}, test_input] }
        request = Rack::MockRequest.env_for("/", :params => "", "CONTENT_TYPE" => "application/x-yaml", :input => test_input)
        body = Rack::RespondToMalformedFormats.new(app).call(request).last

        body.should == test_input
      end
    end

    context "and it is invalid" do
      it "should return a 400 with a message" do
        test_input = "--- what:\nawagasd"
        app = lambda { |env| [200, {"CONTENT_TYPE" => "application/x-yaml"}, test_input] }
        request = Rack::MockRequest.env_for("/", :params => "", "CONTENT_TYPE" => "application/x-yaml", :input => test_input)
        response = Rack::RespondToMalformedFormats.new(app).call(request)

        response[0].should == 400
        response[1]["Content-Type"].should == "application/x-yaml"
        response[2].first.should =~ /.*syntax error.*/
      end
    end
  end
end

