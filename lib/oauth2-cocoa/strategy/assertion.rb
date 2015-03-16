module OAuth2
  module Strategy
    # The Client Assertion Strategy
    #
    # @see http://tools.ietf.org/html/draft-ietf-oauth-v2-10#section-4.1.3
    #
    # Sample usage:
    #   client = OAuth2::Client.new(client_id, client_secret,
    #                               :site => 'http://localhost:8080')
    #
    #   params = {:hmac_secret => "some secret",
    #             # or :private_key => "private key string",
    #             :iss => "http://localhost:3001",
    #             :prn => "me@here.com",
    #             :exp => Time.now.utc.to_i + 3600}
    #
    #   access = client.assertion.get_token(params)
    #   access.token                 # actual access_token string
    #   access.get("/api/stuff")     # making api calls with access token in header
    #
    class Assertion < Base
      def build_assertion(params)
        claims = {
          iss: params[:iss],
          aud: params[:aud],
          prn: params[:prn],
          exp: params[:exp]
        }
        if params[:hmac_secret]
          CocoaSecurity.hmacSha256(claims.to_s, hmacKey: params[:hmac_secret]).hex
        elsif params[:private_key]
          CocoaSecurity.hmacSha256(claims.to_s, hmacKey: params[:private_key]).hex
        end
      end
    end
  end
end
