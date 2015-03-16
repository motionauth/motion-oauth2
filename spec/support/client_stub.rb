class ClientStub
  def initialize(app)
    @app = app
  end

  def call(request)
    headers = {}
    status = 200

    case request.URL.absoluteString
    when "https://api.example.com/success"
      data = "yay".to_data
      headers = { "Content-Type" => "text/awesome" }
    when "https://api.example.com/reflect"
      data = request.HTTPBody.to_s.to_data
    when "https://api.example.com/unauthorized"
      data = OAuth2::Utils.serialize_json(error: error_value, error_description: error_description_value).to_data
      headers = { "Content-Type" => "application/json" }
      status = 401
    when "https://api.example.com/conflict"
      data = "not authorized".to_data
      headers = { "Content-Type" => "text/plain" }
      status = 409
    when "https://api.example.com/redirect"
      data = "".to_data
      case request.HTTPMethod
      when "GET"
        headers = { "Content-Type" => "text/plain", "location" => "/success" }
        status = 302
      when "POST"
        headers = { "Content-Type" => "text/plain", "location" => "/reflect" }
        status = 303
      end
    when "https://api.example.com/error"
      data = "unknown error".to_data
      headers = { "Content-Type" => "text/plain" }
      status = 500
    when "https://api.example.com/empty_get"
      data = nil
      status = 204
    when "https://api.example.com/notfound"
      data = nil
      status = 404
    else
      status, headers, data = @app.call(request)
    end

    return status, headers, data
  end
end
