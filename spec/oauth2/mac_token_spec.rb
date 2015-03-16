describe OAuth2::MACToken do
  VERBS = [:get, :post, :put, :delete]

  def client
    @client ||= OAuth2::Client.new("abc", "def", site: "https://api.example.com")
  end

  def subject
    @subject ||= OAuth2::MACToken.new(client, token, "abc123")
  end

  before do
    RackMotion.use MacTokenStub
  end

  describe "#initialize" do
    it "assigns client and token" do
      subject.client.should.equal(client)
      subject.token.should.equal(token)
    end

    it "assigns secret" do
      subject.secret.should.equal("abc123")
    end

    it "raises on improper algorithm" do
      -> { OAuth2::MACToken.new(client, token, "abc123", algorithm: "invalid-sha") }.should.raise(ArgumentError)
    end
  end

  describe "#request" do
    VERBS.each do |verb|
      it "sends the token in the Authorization header for a #{verb.to_s.upcase} request" do
        subject.post("/token/header").body.should.include("MAC id=\"#{token}\"")
      end
    end
  end

  describe "#header" do
    it "does not generate the same header twice" do
      header = subject.header("get", "https://www.example.com/hello")
      duplicate_header = subject.header("get", "https://www.example.com/hello")

      header.should.not.equal(duplicate_header)
    end

    it "generates the proper format" do
      header = subject.header("get", "https://www.example.com/hello?a=1")
      header.should.match(/MAC id="#{token}", ts="[0-9]+", nonce="[^"]+", mac="[^"]+"/)
    end

    it "passes ArgumentError with an invalid url" do
      -> { subject.header("get", "this-is-not-valid") }.should.raise(ArgumentError)
      -> { subject.header("get", nil) }.should.raise(ArgumentError)
    end
  end

  describe "#signature" do
    it "generates properly" do
      signature = subject.signature(0, "random-string", "get", "https://www.google.com")
      signature.should.equal("rMDjVA3VJj3v1OmxM29QQljKia6msl5rjN83x3bZmi8=")
    end
  end

  describe "#headers" do
    it "is an empty hash" do
      subject.headers.should.equal({})
    end
  end

  describe ".from_access_token" do
    def access_token
      @access_token ||= OAuth2::AccessToken.new(
        client, token,
        expires_at:    1,
        expires_in:    1,
        refresh_token: "abc",
        random:        1
      )
    end

    it "initializes client, token, and secret properly" do
      subject = OAuth2::MACToken.from_access_token(access_token, "hello")
      subject.client.should.equal(client)
      subject.token.should.equal(token)
      subject.secret.should.equal("hello")
    end

    it "initializes configuration options" do
      subject = OAuth2::MACToken.from_access_token(access_token, "hello")
      subject.expires_at.should.equal(1)
      subject.expires_in.should.equal(1)
      subject.refresh_token.should.equal("abc")
    end

    it "initializes params" do
      subject = OAuth2::MACToken.from_access_token(access_token, "hello")
      subject.params.should.equal(random: 1)
    end
  end
end
