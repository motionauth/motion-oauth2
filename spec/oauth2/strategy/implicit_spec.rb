describe OAuth2::Strategy::Implicit do
  def client
    @client ||= OAuth2::Client.new("abc", "def", site: "http://api.example.com")
  end

  def subject
    @subject ||= client.implicit
  end

  describe "#authorize_url" do
    it "includes the client_id" do
      subject.authorize_url.should.include("client_id=abc")
    end

    it "includes the type" do
      subject.authorize_url.should.include("response_type=token")
    end

    it "includes passed in options" do
      cb = "http://myserver.local/oauth/callback".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
      subject.authorize_url(redirect_uri: cb).should.include("redirect_uri=#{cb}")
    end
  end

  describe "#get_token" do
    it "raises NotImplementedError" do
      -> { subject.get_token }.should.raise(NotImplementedError)
    end
  end
end
