describe OAuth2::Strategy::ClientCredentials do
  def client
    @client ||= OAuth2::Client.new("abc", "def", site: "http://api.example.com")
  end

  def subject
    @subject ||= client.client_credentials
  end

  before do
    RackMotion.use ClientCredentialsStub
  end

  describe "#authorize_url" do
    it "raises NotImplementedError" do
      -> { subject.authorize_url }.should.raise(NotImplementedError)
    end
  end

  describe "#authorization" do
    it "generates an Authorization header value for HTTP Basic Authentication" do
      [
        ["abc", "def", "Basic YWJjOmRlZg=="],
        ["xxx", "secret", "Basic eHh4OnNlY3JldA=="]
      ].each do |client_id, client_secret, expected|
        subject.authorization(client_id, client_secret).should.equal(expected)
      end
    end
  end

  %w(json formencoded).each do |mode|
    %w(default basic_auth request_body).each do |auth_scheme|
      describe "#get_token (#{mode}) (#{auth_scheme})" do
        before do
          ClientCredentialsStub.mode = mode
          @access = subject.get_token({}, auth_scheme == "default" ? {} : { "auth_scheme" => auth_scheme })
        end

        it "returns AccessToken with same Client" do
          @access.client.should.equal(client)
        end

        it "returns AccessToken with #token" do
          @access.token.should.equal("salmon")
        end

        it "returns AccessToken without #refresh_token" do
          @access.refresh_token.should.equal(nil)
        end

        it "returns AccessToken with #expires_in" do
          @access.expires_in.should.equal(600)
        end

        it "returns AccessToken with #expires_at" do
          @access.expires_at.should.not.equal(nil)
        end
      end
    end
  end
end
