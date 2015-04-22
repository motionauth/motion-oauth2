class AccessTokenStub
  def initialize(app)
    @app = app
  end

  def call(request)
    headers = {}
    status = 200

    case request.URL.absoluteString
    when "https://api.example.com/token/header"
      data = request.valueForHTTPHeaderField("Authorization").to_data
    when "https://api.example.com/token/query?access_token=#{token}"
      data = request.URL.query.split("=").last.to_data
    when "https://api.example.com/token/body"
      data = request.HTTPBody
    when "https://api.example.com/oauth/token"
      data = refresh_body.to_data
      headers = { "Content-Type" => "application/json" }
    else
      status, headers, data = @app.call(request)
    end

    return status, headers, data
  end

  def refresh_body
    OAuth2::Utils.serialize_json(
      access_token:  "refreshed_foo",
      expires_in:    600,
      refresh_token: self.class.refresh_token
    )
  end

  class << self
    attr_accessor :refresh_token
  end
end
