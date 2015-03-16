module OAuth2
  class Utils
    class ParserError < StandardError; end

    # Serialize a JSON object
    # @return [String]
    def self.serialize_json(obj)
      NSJSONSerialization.dataWithJSONObject(obj, options: 0, error: nil).to_str
    end

    # Returns a Hash from a URL query string
    # @param query [String]
    # @return [Hash]
    def self.params_from_query(query)
      query ||= ""
      key_values = query.split("&")
      hash = {}

      key_values.each do |key_value|
        key_value = key_value.split("=")
        hash[key_value[0].to_sym] = key_value[1]
      end

      hash.with_indifferent_access
    end

    # Parses a string or data object and converts it in data structure.
    #
    # @param [String, NSData] str_data the string or data to serialize.
    # @raise [ParserError] If the parsing of the passed string/data isn't valid.
    # @return [Hash, Array, NilClass] the converted data structure, nil if the incoming string isn't valid.
    def self.parse_json(str_data, &block)
      return nil unless str_data
      data = str_data.respond_to?("dataUsingEncoding:") ? str_data.dataUsingEncoding(NSUTF8StringEncoding) : str_data
      opts = NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
      error = Pointer.new(:id)
      obj = NSJSONSerialization.JSONObjectWithData(data, options: opts, error: error)
      fail ParserError, error[0].description if error[0]
      if block_given?
        yield obj
      else
        obj
      end
    end

    # Returns a URL query string from a params Hash
    # @param params [Hash]
    # @return [String]
    def self.query_from_params(params)
      key_values = []
      params.each do |key, value|
        value = value.to_s.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        key_values << "#{key}=#{value}"
      end

      if key_values.length > 0
        "#{key_values.join('&')}"
      else
        ""
      end
    end
  end
end
