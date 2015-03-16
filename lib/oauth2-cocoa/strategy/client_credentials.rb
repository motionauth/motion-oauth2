module OAuth2
  module Strategy
    # The Client Credentials Strategy
    #
    # @see http://tools.ietf.org/html/draft-ietf-oauth-v2-15#section-4.4
    class ClientCredentials < Base
      # Returns the Authorization header value for Basic Authentication
      #
      # @param [String] The client ID
      # @param [String] the client secret
      def authorization(client_id, client_secret)
        encoder = CocoaSecurityEncoder.new
        authorization = encoder.base64("#{client_id}:#{client_secret}".to_data).gsub("\n", "")
        "Basic #{authorization}"
      end
    end
  end
end
