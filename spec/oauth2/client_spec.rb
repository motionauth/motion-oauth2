describe OAuth2::Client do
  def subject
    @subject ||= OAuth2::Client.new("abc", "def", site: "https://api.example.com")
  end

  before do
    RackMotion.use ClientStub
  end

  describe "#initialize" do
    it "assigns id and secret" do
      subject.id.should.equal("abc")
      subject.secret.should.equal("def")
    end

    it "assigns site from the options hash" do
      subject.site.should.equal("https://api.example.com")
    end

    it "assigns OAuth2::Connection#host" do
      subject.connection.host.should.equal("api.example.com")
    end

    it "leaves Faraday::Connection#ssl unset" do
      subject.connection.ssl.should.be.empty
    end

    it "defaults raise_errors to true" do
      subject.options[:raise_errors].should.equal(true)
    end

    it "allows true/false for raise_errors option" do
      client = OAuth2::Client.new("abc", "def", site: "https://api.example.com", raise_errors: false)
      client.options[:raise_errors].should.equal(false)
      client = OAuth2::Client.new("abc", "def", site: "https://api.example.com", raise_errors: true)
      client.options[:raise_errors].should.equal(true)
    end

    it "allows override of raise_errors option" do
      client = OAuth2::Client.new("abc", "def", site: "https://api.example.com", raise_errors: true)
      client.options[:raise_errors].should.equal(true)
      -> { client.request(:get, "/notfound") }.should.raise(OAuth2::Error)
      response = client.request(:get, "/notfound", raise_errors: false)
      response.status.should.equal(404)
    end

    it "allows get/post for access_token_method option" do
      client = OAuth2::Client.new("abc", "def", site: "https://api.example.com", access_token_method: :get)
      client.options[:access_token_method].should.equal(:get)
      client = OAuth2::Client.new("abc", "def", site: "https://api.example.com", access_token_method: :post)
      client.options[:access_token_method].should.equal(:post)
    end

    it "does not mutate the opts hash argument" do
      opts = { site: "http://example.com/" }
      opts2 = opts.dup
      OAuth2::Client.new "abc", "def", opts
      opts.should.equal(opts2)
    end
  end

  %w(authorize token).each do |url_type|
    describe ":#{url_type}_url option" do
      it "defaults to a path of /oauth/#{url_type}" do
        subject.send("#{url_type}_url").should.equal("https://api.example.com/oauth/#{url_type}")
      end

      it "is settable via the :#{url_type}_url option" do
        subject.options[:"#{url_type}_url"] = "/oauth/custom"
        subject.send("#{url_type}_url").should.equal("https://api.example.com/oauth/custom")
      end

      it "allows a different host than the site" do
        subject.options[:"#{url_type}_url"] = "https://api.foo.com/oauth/custom"
        subject.send("#{url_type}_url").should.equal("https://api.foo.com/oauth/custom")
      end
    end
  end

  describe "#request" do
    it "works with a null response body" do
      subject.request(:get, "empty_get").body.should.equal("")
    end

    it "returns on a successful response" do
      response = subject.request(:get, "/success")
      response.body.should.equal("yay")
      response.status.should.equal(200)
      response.headers.should.equal("Content-Type" => "text/awesome")
    end

    # it "outputs to $stdout when OAUTH_DEBUG=true" do
    #   allow(ENV).to receive(:[]).with("http_proxy").and_return(nil)
    #   allow(ENV).to receive(:[]).with("OAUTH_DEBUG").and_return("true")
    #   output = capture_output do
    #     subject.request(:get, "/success")
    #   end
    #
    #   expect(output).to include "INFO -- : get https://api.example.com/success", "INFO -- : get https://api.example.com/success"
    # end

    it "posts a body" do
      response = subject.request(:post, "/reflect", body: "foo=bar")
      response.body.should.equal("foo=bar")
    end

    it "follows redirects properly" do
      response = subject.request(:get, "/redirect")
      response.body.should.equal("yay")
      response.status.should.equal(200)
      response.headers.should.equal("Content-Type" => "text/awesome")
    end

    it "redirects using GET on a 303" do
      response = subject.request(:post, "/redirect", body: "foo=bar")
      response.body.should.be.empty
      response.status.should.equal(200)
    end

    it "obeys the :max_redirects option" do
      max_redirects = subject.options[:max_redirects]
      subject.options[:max_redirects] = 0
      response = subject.request(:get, "/redirect")
      response.status.should.equal(302)
      subject.options[:max_redirects] = max_redirects
    end

    it "returns if raise_errors is false" do
      subject.options[:raise_errors] = false
      response = subject.request(:get, "/unauthorized")

      response.status.should.equal(401)
      response.error.should.not.equal(nil)
    end

    %w(/unauthorized /conflict /error).each do |error_path|
      it "raises OAuth2::Error on error response to path #{error_path}" do
        subject.options[:raise_errors] = true
        -> { subject.request(:get, error_path) }.should.raise(OAuth2::Error)
      end
    end

    # it "parses OAuth2 standard error response" do
    #   begin
    #     subject.request(:get, "/unauthorized")
    #   rescue StandardError => e
    #     e.code.should.equal(error_value)
    #     e.description.should.equal(error_description_value)
    #     e.to_s.should.match(/#{error_value}/)
    #     e.to_s.should.match(/#{error_description_value}/)
    #   end
    # end

    it "provides the response in the Exception" do
      begin
        subject.request(:get, "/error")
      rescue StandardError => e
        e.response.should.not.equal(nil)
        e.to_s.should.match(/unknown error/)
      end
    end
  end

  it "instantiates an AuthCode strategy with this client" do
    subject.auth_code.is_a?(OAuth2::Strategy::AuthCode).should.equal(true)
  end

  it "instantiates an Implicit strategy with this client" do
    subject.implicit.is_a?(OAuth2::Strategy::Implicit).should.equal(true)
  end

  context "with SSL options" do
    it "passes the SSL options along to OAuth2::Connection#ssl" do
      client = OAuth2::Client.new("abc", "def", site: "https://api.example.com", ssl: { ca_file: "foo.pem" })
      client.connection.ssl.fetch(:ca_file).should.equal("foo.pem")
    end
  end
end
