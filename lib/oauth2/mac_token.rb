module OAuth2
  class MACToken < AccessToken
    # Generates a MACToken from an AccessToken and secret
    #
    # @param [AccessToken] token the OAuth2::Token instance
    # @option [String] secret the secret key value
    # @param [Hash] opts the options to create the Access Token with
    # @see MACToken#initialize
    def self.from_access_token(token, secret, options = {})
      new(token.client, token.token, secret, token.params.merge(
        refresh_token: token.refresh_token,
        expires_in:    token.expires_in,
        expires_at:    token.expires_at
      ).merge(options))
    end

    attr_reader :algorithm, :secret

    # Initalize a MACToken
    #
    # @param [Client] client the OAuth2::Client instance
    # @param [String] token the Access Token value
    # @option [String] secret the secret key value
    # @param [Hash] opts the options to create the Access Token with
    # @option opts [String] :refresh_token (nil) the refresh_token value
    # @option opts [FixNum, String] :expires_in (nil) the number of seconds in which the AccessToken will expire
    # @option opts [FixNum, String] :expires_at (nil) the epoch time in seconds in which AccessToken will expire
    # @option opts [FixNum, String] :algorithm (hmac-sha-256) the algorithm to use for the HMAC digest (one of 'hmac-sha-256', 'hmac-sha-1')
    def initialize(client, token, secret, opts = {})
      @secret = secret
      self.algorithm = opts.delete(:algorithm) || "hmac-sha-256"

      super(client, token, opts)
    end

    # Make a request with the MAC Token
    #
    # @param [Symbol] verb the HTTP request method
    # @param [String] path the HTTP URL path of the request
    # @param [Hash] opts the options to make the request with
    # @see Client#request
    def request(verb, path, opts = {}, &block)
      url = client.connection.build_url(path, opts[:params]).to_s

      opts[:headers] ||= {}
      opts[:headers].merge!("Authorization" => header(verb, url))

      @client.request(verb, path, opts, &block)
    end

    # Get the headers hash (always an empty hash)
    def headers
      {}
    end

    # Generate the MAC header
    #
    # @param [Symbol] verb the HTTP request method
    # @param [String] url the HTTP URL path of the request
    def header(verb, url)
      timestamp = Time.now.utc.to_i
      nonce = generate_nonce
      mac = signature(timestamp, nonce, verb, url)
      "MAC id=\"#{token}\", ts=\"#{timestamp}\", nonce=\"#{nonce}\", mac=\"#{mac}\""
    end

  private

    # No-op since we need the verb and path
    # and the MAC always goes in a header
    def token=(_)
    end
  end
end
