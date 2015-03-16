describe OAuth2::Strategy::AuthCode do
  def client
    @client ||= OAuth2::Client.new("abc", "def", site: "http://api.example.com")
  end

  def subject
    @subject ||= client.auth_code
  end

  before do
    RackMotion.use AuthCodeStub
  end

  describe "#authorize_url" do
    it "includes the client_id" do
      subject.authorize_url.should.include("client_id=abc")
    end

    it "includes the type" do
      subject.authorize_url.should.include("response_type=code")
    end

    it "includes passed in options" do
      cb = "http://myserver.local/oauth/callback".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
      subject.authorize_url(redirect_uri: cb).should.include("redirect_uri=#{cb}")
    end
  end

  %w(json formencoded from_facebook).each do |mode|
    [:get, :post].each do |verb|
      describe "#get_token (#{mode}, access_token_method=#{verb}" do
        before do
          AuthCodeStub.mode = mode
          client.options[:token_method] = verb
          @access = subject.get_token("sushi")
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
          @access.expires_at.is_a?(Integer).should.equal(true)
        end

        it "returns AccessToken with params accessible via []" do
          @access["extra_param"].should.equal("steve")
        end
      end
    end
  end
end
