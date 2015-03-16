module OAuth2
  class Response
    attr_accessor :error, :options

    # Adds a new content type parser.
    #
    # @param [Symbol] key A descriptive symbol key such as :json or :query.
    # @param [Array] One or more mime types to which this parser applies.
    # @yield [String] A block returning parsed content.
    def self.register_parser(key, mime_types, &block)
      key = key.to_sym
      PARSERS[key] = block
      Array(mime_types).each do |mime_type|
        CONTENT_TYPES[mime_type] = key
      end
    end

    # Procs that, when called, will parse a response body according
    # to the specified format.
    PARSERS = {
      json:  ->(body) { Utils.parse_json(body) rescue body }, # rubocop:disable RescueModifier
      query: ->(body) { Utils.params_from_query(body) },
      text:  ->(body) { body }
    }

    # Content type assignments for various potential HTTP content types.
    CONTENT_TYPES = {
      "application/json"                  => :json,
      "text/javascript"                   => :json,
      "application/x-www-form-urlencoded" => :query,
      "text/plain"                        => :text
    }

    # The parsed response body.
    #   Will attempt to parse application/x-www-form-urlencoded and
    #   application/json Content-Type response bodies
    def parsed
      return nil unless PARSERS.key?(parser)
      @parsed ||= PARSERS[parser].call(body)
    end

    # Determines the parser that will be used to supply the content of #parsed
    def parser
      return options[:parse].to_sym if PARSERS.key?(options[:parse])
      CONTENT_TYPES[content_type]
    end
  end
end

OAuth2::Response.register_parser(:xml, ["text/xml", "application/rss+xml", "application/rdf+xml", "application/atom+xml"]) do |body|
  begin
    # TODO: PARSE XML
    # MultiXml.parse(body)
    body
  rescue
    body
  end
end
