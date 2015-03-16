class AssertionStub
  def initialize(app)
    @app = app
  end

  def call(request)
    headers = {}
    status = 200

    case request.URL.absoluteString
    when "http://api.example.com/oauth/token"
      case self.class.mode
      when "formencoded"
        data = "expires_in=600&access_token=salmon&refresh_token=trout".to_data
        headers = { "Content-Type" => "application/x-www-form-urlencoded" }
      when "json"
        data = '{"expires_in":600,"access_token":"salmon","refresh_token":"trout"}'.to_data
        headers = { "Content-Type" => "application/json" }
      end
    else
      status, headers, data = @app.call(request)
    end

    return status, headers, data
  end

  class << self
    attr_accessor :mode
  end
end
