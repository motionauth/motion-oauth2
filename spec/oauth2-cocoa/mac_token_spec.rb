describe OAuth2::MACToken do
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
    it "defaults algorithm to hmac-sha-256" do
      subject.algorithm.should.equal("hmacSha256:hmacKey")
    end

    it "handles hmac-sha-256" do
      mac = OAuth2::MACToken.new(client, token, "abc123", algorithm: "hmac-sha-256")
      mac.algorithm.should.equal("hmacSha256:hmacKey")
    end

    it "handles hmac-sha-1" do
      mac = OAuth2::MACToken.new(client, token, "abc123", algorithm: "hmac-sha-1")
      mac.algorithm.should.equal("hmacSha1:hmacKey")
    end
  end
end
