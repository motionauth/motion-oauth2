describe OAuth2::Strategy::Password do
  def client
    @client ||= OAuth2::Client.new("abc", "def", site: "http://api.example.com")
  end

  def subject
    @subject ||= client.password
  end

  before do
    RackMotion.use PasswordStub
  end

  describe "#authorize_url" do
    it "raises NotImplementedError" do
      -> { subject.authorize_url }.should.raise(NotImplementedError)
    end
  end

  %w(json formencoded).each do |mode|
    describe "#get_token (#{mode})" do
      before do
        PasswordStub.mode = mode
        @access = subject.get_token("username", "password")
      end

      it "returns AccessToken with same Client" do
        @access.client.should.equal(client)
      end

      it "returns AccessToken with #token" do
        @access.token.should.equal("salmon")
      end

      it "returns AccessToken with #refresh_token" do
        @access.refresh_token.should.equal("trout")
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
