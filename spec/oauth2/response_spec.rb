describe OAuth2::Response do
  def status
    @status ||= 200
  end

  def headers
    @headers ||= { "foo" => "bar" }
  end

  def body
    @body ||= "foo"
  end

  describe "#initialize" do
    it "returns the status, headers and body" do
      subject = OAuth2::Response.new(
        data:    body.dataUsingEncoding(NSUTF8StringEncoding),
        headers: headers,
        status:  status
      )
      subject.headers.should.equal(headers)
      subject.status.should.equal(status)
      subject.body.should.equal(body)
    end
  end

  describe ".register_parser" do
    before do
      OAuth2::Response.register_parser(:foobar, "application/foo-bar") do |body|
        "foobar #{body}"
      end
    end

    it "adds to the content types and parsers" do
      OAuth2::Response::PARSERS.keys.should.include(:foobar)
      OAuth2::Response::CONTENT_TYPES.keys.should.include("application/foo-bar")
    end

    it "is able to parse that content type automatically" do
      response = OAuth2::Response.new(
        data:    "baz".dataUsingEncoding(NSUTF8StringEncoding),
        headers: { "Content-Type" => "application/foo-bar" },
        status:  200
      )
      response.parsed.should.equal("foobar baz")
    end
  end

  describe "#parsed" do
    it "parses application/x-www-form-urlencoded body" do
      body = "foo=bar&answer=42"
      headers = { "Content-Type" => "application/x-www-form-urlencoded" }
      subject = OAuth2::Response.new(
        data:    body.dataUsingEncoding(NSUTF8StringEncoding),
        headers: headers,
        status:  200
      )
      subject.parsed.keys.size.should.equal(2)
      subject.parsed["foo"].should.equal("bar")
      subject.parsed["answer"].should.equal("42")
    end

    it "parses application/json body" do
      body = OAuth2::Utils.serialize_json(foo: "bar", answer: 42)
      headers = { "Content-Type" => "application/json" }
      subject = OAuth2::Response.new(
        data:    body.dataUsingEncoding(NSUTF8StringEncoding),
        headers: headers,
        status:  200
      )
      subject.parsed.keys.size.should.equal(2)
      subject.parsed["foo"].should.equal("bar")
      subject.parsed["answer"].should.equal(42)
    end

    it "doesn't try to parse other content-types" do
      body = "<!DOCTYPE html><html><head></head><body></body></html>"
      headers = { "Content-Type" => "text/html" }

      subject = OAuth2::Response.new(
        data:    body.dataUsingEncoding(NSUTF8StringEncoding),
        headers: headers,
        status:  200
      )

      subject.parsed.should.equal(nil)
    end
  end

  # context "xml parser registration" do
  #   it "tries to load multi_xml and use it" do
  #     expect(OAuth2::Response::PARSERS[:xml]).not_to be_nil
  #   end
  #
  #   it "is able to parse xml" do
  #     headers = {"Content-Type" => "text/xml"}
  #     body = "<?xml version="1.0" standalone="yes" ?><foo><bar>baz</bar></foo>"
  #
  #     response = double("response", :headers => headers, :body => body)
  #     expect(OAuth2::Response.new(response).parsed).to eq("foo" => {"bar" => "baz"})
  #   end
  # end
end
