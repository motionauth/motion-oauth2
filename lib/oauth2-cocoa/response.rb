module OAuth2
  class Response
    attr_reader :body
    attr_accessor :data, :headers, :response, :status

    # Initializes a Response instance
    #
    # @param params [Hash]
    # @option params [NSData] :data
    # @option params [Hash] :headers
    # @option params [Integer] :status
    # @param data [NSData]
    # @param opts [Hash] options in which to initialize the instance
    # @option opts [Symbol] :parse (:automatic) how to parse the response body.  one of :query (for x-www-form-urlencoded),
    #   :json, or :automatic (determined by Content-Type response header)
    def initialize(params = {}, opts = {})
      params.each do |key, value|
        self.send("#{key}=", value)
      end
      @options = { parse: :automatic }.merge(opts)
    end

    # The HTTP response body
    def body
      return "" unless data.is_a?(NSData)
      NSString.alloc.initWithData(data, encoding: NSUTF8StringEncoding)
    end

    # Attempts to determine the content type of the response.
    def content_type
      ((self.headers.values_at("content-type", "Content-Type").compact.first || "").split(";").first || "").strip
    end
  end
end
