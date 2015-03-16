class MacTokenStub
  def initialize(app)
    @app = app
  end

  def call(request)
    headers = {}
    status = 200

    case request.URL.absoluteString
    when "https://api.example.com/token/header"
      data = request.valueForHTTPHeaderField("Authorization").to_data
    else
      status, headers, data = @app.call(request)
    end

    return status, headers, data
  end
end
