class AuthCodeStub
  def initialize(app)
    @app = app
  end

  def call(request)
    headers = {}
    status = 200

    case request.URL.absoluteString
    when "http://api.example.com/oauth/token?grant_type=authorization_code&code=sushi&client_id=abc&client_secret=def"
      case self.class.mode
      when "formencoded"
        data = kvform_token.to_data
        headers = { "Content-Type" => "application/x-www-form-urlencoded" }
      when "json"
        data = json_token.to_data
        headers = { "Content-Type" => "application/json" }
      when "from_facebook"
        data = facebook_token.to_data
        headers = { "Content-Type" => "application/x-www-form-urlencoded" }
      end
    when "http://api.example.com/oauth/token"
      case self.class.mode
      when "formencoded"
        data = kvform_token.to_data
        headers = { "Content-Type" => "application/x-www-form-urlencoded" }
      when "json"
        data = json_token.to_data
        headers = { "Content-Type" => "application/json" }
      when "from_facebook"
        data = facebook_token.to_data
        headers = { "Content-Type" => "application/x-www-form-urlencoded" }
      end
    else
      status, headers, data = @app.call(request)
    end

    return status, headers, data
  end

  def kvform_token
    @kvform_token ||= "expires_in=600&access_token=salmon&refresh_token=trout&extra_param=steve"
  end

  def facebook_token
    @facebook_token ||= kvform_token.gsub("_in", "")
  end

  def json_token
    OAuth2::Utils.serialize_json(
      expires_in:    600,
      access_token:  "salmon",
      refresh_token: "trout",
      extra_param:   "steve"
    )
  end

  class << self
    attr_accessor :mode
  end
end
