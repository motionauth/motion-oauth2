module OAuth2
  class Connection
    class ConnectionError < StandardError; end

    # Public: Initializes a new Faraday::Connection.
    #
    # url     - NSURL or String base URL to use as a prefix for all
    #           requests (optional).
    # options - Hash
    #           :url     - NSURL or String base URL (default: "http:/").
    #           :params  - Hash of URI query unencoded key/value pairs.
    #           :headers - Hash of unencoded HTTP header key/value pairs.
    #           :request - Hash of request options.
    #           :ssl     - Hash of SSL options.
    def initialize(url = nil, options = {})
      if url.is_a?(Hash)
        options = url.with_indifferent_access
        url = options[:url]
      else
        options = options.with_indifferent_access
      end

      @headers = {}.with_indifferent_access
      @options = {}.with_indifferent_access
      @params  = {}.with_indifferent_access
      @ssl     = {}.with_indifferent_access

      url = NSURL.URLWithString(url) if url.is_a?(String)
      self.url_prefix = url || NSURL.URLWithString("http:/")

      @headers.update(options[:headers]) if options[:headers]
      @options.update(options[:request]) if options[:request]
      @params.update(options[:params])   if options[:params]
      @ssl.update(options[:ssl])         if options[:ssl]

      @headers[:user_agent] ||= "Motion-OAuth2 v#{Version}"
    end

    # Public: Takes a relative url for a request and combines it with the defaults
    # set on the connection instance.
    #
    #   conn = OAuth2::Connection.new { ... }
    #   conn.url_prefix = "https://sushi.com/api?token=abc"
    #   conn.scheme      # => https
    #   conn.path_prefix # => "/api"
    #
    #   conn.build_url("nigiri?page=2")      # => https://sushi.com/api/nigiri?token=abc&page=2
    #   conn.build_url("nigiri", :page => 2) # => https://sushi.com/api/nigiri?token=abc&page=2
    #
    def build_url(url = nil, extra_params = nil)
      url = url.absoluteString if url.is_a?(NSURL)
      nsurl = NSURL.URLWithString(url, relativeToURL: self.url_prefix)
      base_url = nsurl.absoluteString.gsub("?#{nsurl.query}", "")

      url_params = Utils.params_from_query(nsurl.query)
      query_values = params.dup.merge(url_params)
      query_values.update(extra_params) if extra_params

      if query_values.length > 0
        query_string = Utils.query_from_params(query_values)
        "#{base_url}?#{query_string}"
      else
        base_url
      end
    end

    # The host of the URL
    # @return [String]
    def host
      self.url_prefix.host
    end

    # Builds and runs the NSURLRequest.
    #
    # method  - The Symbol HTTP method.
    # url     - The String or NSURL to access.
    # body    - The String body
    # headers - Hash of unencoded HTTP header key/value pairs.
    # parse   - Response parse options @see Response::initialize
    #
    # Returns a OAuth2::Response.
    def run_request(method, url, body, headers, parse)
      unless METHODS.include?(method)
        fail ArgumentError, "unknown http method: #{method}"
      end

      url = NSURL.URLWithString(url) if url.is_a?(String)
      request = NSMutableURLRequest.requestWithURL(url)
      request.setHTTPMethod(method)

      if body
        body = Utils.query_from_params(body) if body.is_a?(Hash)
        request.setHTTPBody(body)
      end

      if headers
        headers.each do |key, value|
          request.addValue(value, forHTTPHeaderField: key)
        end
      end

      response = Pointer.new(:object)
      error = Pointer.new(:object)
      data = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: error)

      if error[0]
        if error[0].code == NSURLErrorUserCancelledAuthentication
          return Response.new({
            data:     nil,
            error:    error[0],
            headers:  {},
            response: nil,
            status:   401
          }, {
            parse: parse
          })
        else
          fail ConnectionError, error[0].localizedDescription
        end
      end

      Response.new({
        data:     data,
        headers:  response[0].allHeaderFields,
        response: response[0],
        status:   response[0].statusCode
      }, {
        parse: parse
      })
    end

    # Public: Parses the giving url with URI and stores the individual
    # components in this connection.  These components serve as defaults for
    # requests made by this connection.
    #
    # url - A String or NSURL.
    #
    # Examples
    #
    #   conn = Faraday::Connection.new { ... }
    #   conn.url_prefix = "https://sushi.com/api"
    #   conn.scheme      # => https
    #   conn.path_prefix # => "/api"
    #
    #   conn.get("nigiri?page=2") # accesses https://sushi.com/api/nigiri
    #
    # Returns the parsed URI from teh given input..
    def url_prefix=(url)
      url = NSURL.URLWithString(url) if url.is_a?(String)
      @url_prefix = url

      url_params = Utils.params_from_query(@url_prefix.query)
      self.params = self.params.merge(url_params)

      @url_prefix = NSURL.URLWithString(@url_prefix.absoluteString.gsub("?#{@url_prefix.query}", ""))
    end
  end
end
