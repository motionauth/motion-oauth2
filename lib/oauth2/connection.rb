module OAuth2
  class Connection
    # A Set of allowed HTTP verbs.
    METHODS = [:get, :post, :put, :delete, :head, :patch, :options]

    # Public: Returns a Hash of URI query unencoded key/value pairs.
    attr_reader :params

    # Public: Returns a Hash of unencoded HTTP header key/value pairs.
    attr_reader :headers

    # Public: Returns a URI with the prefix used for all requests from this
    # Connection.  This includes a default host name, scheme, port, and path.
    attr_reader :url_prefix

    # Public: Returns the Faraday::Builder for this Connection.
    attr_reader :builder

    # Public: Returns a Hash of the request options.
    attr_reader :options

    # Public: Returns a Hash of the SSL options.
    attr_reader :ssl

    # Public: Sets the Hash of unencoded HTTP header key/value pairs.
    def headers=(hash)
      @headers.replace(hash)
    end

    # Public: Sets the Hash of URI query unencoded key/value pairs.
    def params=(hash)
      @params.replace(hash)
    end
  end
end
