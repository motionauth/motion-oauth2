describe OAuth2::AccessToken do
  VERBS = [:get, :post, :put, :delete]

  def client
    @client ||= OAuth2::Client.new("abc", "def", site: "https://api.example.com")
  end

  def subject
    @subject ||= OAuth2::AccessToken.new(client, token)
  end

  before do
    RackMotion.use AccessTokenStub
  end

  describe "#initialize" do
    it "assigns client and token" do
      subject.client.should.equal(client)
      subject.token.should.equal(token)
    end

    it "assigns extra params" do
      target = OAuth2::AccessToken.new(client, token, "foo" => "bar")
      target.params.should.include("foo")
      target.params["foo"].should.equal("bar")
    end

    def assert_initialized_token(target)
      target.token.should.equal(token)
      target.expires?.should.equal(true)
      target.params.keys.should.include("foo")
      target.params["foo"].should.equal("bar")
    end

    it "initializes with a Hash" do
      hash = { access_token: token, expires_at: Time.now.to_i + 200, "foo" => "bar"}
      target = OAuth2::AccessToken.from_hash(client, hash)
      assert_initialized_token(target)
    end

    it "initalizes with a form-urlencoded key/value string" do
      kvform = "access_token=#{token}&expires_at=#{Time.now.to_i + 200}&foo=bar"
      target = OAuth2::AccessToken.from_kvform(client, kvform)
      assert_initialized_token(target)
    end

    it "sets options" do
      target = OAuth2::AccessToken.new(client, token, param_name: "foo", header_format: "Bearer %", mode: :body)
      target.options[:param_name].should.equal("foo")
      target.options[:header_format].should.equal("Bearer %")
      target.options[:mode].should.equal(:body)
    end

    it "initializes with a string expires_at" do
      hash = { access_token: token, expires_at: "1361396829", "foo" => "bar" }
      target = OAuth2::AccessToken.from_hash(client, hash)
      assert_initialized_token(target)
      target.expires_at.is_a?(Integer).should.equal(true)
    end
  end

  describe "#request" do
    context ":mode => :header" do
      def client
        @client ||= OAuth2::Client.new("abc", "def", site: "https://api.example.com")
      end

      def subject
        @subject ||= OAuth2::AccessToken.new(client, token)
      end

      before do
        subject.options[:mode] = :header
        RackMotion.use AccessTokenStub
      end

      VERBS.each do |verb|
        it "sends the token in the Authorization header for a #{verb.to_s.upcase} request" do
          subject.post("/token/header").body.should.include(token)
        end
      end
    end

    context ":mode => :query" do
      def client
        @client ||= OAuth2::Client.new("abc", "def", site: "https://api.example.com")
      end

      def subject
        @subject ||= OAuth2::AccessToken.new(client, token)
      end

      before do
        subject.options[:mode] = :query
        RackMotion.use AccessTokenStub
      end

      VERBS.each do |verb|
        it "sends the token in the Authorization header for a #{verb.to_s.upcase} request" do
          subject.post("/token/query").body.should.equal(token)
        end
      end
    end

    context ":mode => :body" do
      def client
        @client ||= OAuth2::Client.new("abc", "def", site: "https://api.example.com")
      end

      def subject
        @subject ||= OAuth2::AccessToken.new(client, token)
      end

      before do
        subject.options[:mode] = :body
        RackMotion.use AccessTokenStub
      end

      VERBS.each do |verb|
        it "sends the token in the Authorization header for a #{verb.to_s.upcase} request" do
          subject.post("/token/body").body.split("=").last.should.equal(token)
        end
      end
    end
  end

  describe "#expires?" do
    it "is false if there is no expires_at" do
      OAuth2::AccessToken.new(client, token).expires?.should.not.equal(true)
    end

    it "is true if there is an expires_in" do
      OAuth2::AccessToken.new(client, token, refresh_token: "abaca", expires_in: 600).expires?.should.equal(true)
    end

    it "is true if there is an expires_at" do
      OAuth2::AccessToken.new(client, token, refresh_token: "abaca", expires_in: Time.now.getutc.to_i + 600).expires?.should.equal(true)
    end
  end

  describe "#expired?" do
    it "is false if there is no expires_in or expires_at" do
      OAuth2::AccessToken.new(client, token).expired?.should.not.equal(true)
    end

    it "is false if expires_in is in the future" do
      OAuth2::AccessToken.new(client, token, refresh_token: "abaca", expires_in: 10_800).expired?.should.not.equal(true)
    end

    it "is true if expires_at is in the past" do
      access = OAuth2::AccessToken.new(client, token, refresh_token: "abaca", expires_in: -600)
      access.expired?.should.equal(true)
    end

  end

  describe "#refresh!" do
    def access
      @access ||= OAuth2::AccessToken.new(
        client,
        token,
        refresh_token: "abaca",
        expires_in:    600,
        param_name:    "o_param"
      )
    end

    it "returns a refresh token with appropriate values carried over" do
      AccessTokenStub.refresh_token = "refresh_bar"
      refreshed = access.refresh!
      access.client.should.equal(refreshed.client)
      access.options[:param_name].should.equal(refreshed.options[:param_name])
    end

    context "with a nil refresh_token in the response" do
      it "copies the refresh_token from the original token" do
        AccessTokenStub.refresh_token = nil
        refreshed = access.refresh!
        refreshed.refresh_token.should.equal(access.refresh_token)
      end
    end
  end

  describe "#to_hash" do
    it "return a hash equals to the hash used to initialize access token" do
      hash = { access_token: token, refresh_token: "foobar", expires_at: Time.now.to_i + 200, "foo" => "bar" }
      access_token = OAuth2::AccessToken.from_hash(client, hash.clone)
      access_token.to_hash.should.equal(hash)
    end
  end
end
