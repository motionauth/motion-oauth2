class DebugStub
  def initialize(app)
    @app = app
  end

  def call(request)
    mp "REQUEST URL:"
    mp request.URL.absoluteString

    mp "REQUEST HEADERS:"
    mp request.allHTTPHeaderFields

    status, headers, data = @app.call(request)

    mp "RESPONSE STATUS:"
    mp status

    mp "RESPONSE HEADERS:"
    mp headers

    mp "RESPONSE DATA:"
    mp data

    return status, headers, data
  end
end
