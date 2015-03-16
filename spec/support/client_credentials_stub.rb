class ClientCredentialsStub
  def initialize(app)
    @app = app
  end

  def call(request)
    headers = {}
    status = 200

    case request.URL.absoluteString
    when "http://api.example.com/oauth/token"
      hash = OAuth2::Utils.params_from_query(request.HTTPBody.to_s)

      if hash[:client_id] != "abc" && hash[:client_secret] != "def" && hash[:grant_type] == "client_credentials"
        encoded_authorization = request.valueForHTTPHeaderField("Authorization").to_s.split(" ", 2)[1]
        decoder = CocoaSecurityDecoder.new
        decoded_authorization = NSString.alloc.initWithData(decoder.base64(encoded_authorization), encoding: NSUTF8StringEncoding)
        client_id, client_secret = decoded_authorization.to_s.split(":", 2)
        client_id == "abc" && client_secret == "def" || fail(StandardError, "Missing client_id and client_secret")
      end

      case self.class.mode
      when "formencoded"
        data = kvform_token.to_data
        headers = { "Content-Type" => "application/x-www-form-urlencoded" }
      when "json"
        data = json_token.to_data
        headers = { "Content-Type" => "application/json" }
      end
    else
      mp "ELSE"
      mp request.URL.absoluteString
      status, headers, data = @app.call(request)
    end

    return status, headers, data
  end

  def kvform_token
    @kvform_token ||= "expires_in=600&access_token=salmon&refresh_token=trout"
  end

  def json_token
    @json_token ||= '{"expires_in":600,"access_token":"salmon","refresh_token":"trout"}'
  end

  class << self
    attr_accessor :mode
  end
end
