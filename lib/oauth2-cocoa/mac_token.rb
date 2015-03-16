module OAuth2
  class MACToken < AccessToken
    # Set the HMAC algorithm
    #
    # @param [String] alg the algorithm to use (one of 'hmac-sha-1', 'hmac-sha-256')
    def algorithm=(alg)
      @algorithm = begin
        case alg.to_s
        when "hmac-sha-1"
          "hmacSha1:hmacKey"
        when "hmac-sha-256"
          "hmacSha256:hmacKey"
        else
          fail(ArgumentError, "Unsupported algorithm")
        end
      end
    end

    # Generate the Base64-encoded HMAC digest signature
    #
    # @param [Fixnum] timestamp the timestamp of the request in seconds since epoch
    # @param [String] nonce the MAC header nonce
    # @param [Symbol] verb the HTTP request method
    # @param [String] url the HTTP URL path of the request
    def signature(timestamp, nonce, verb, url)
      nsurl = NSURL.URLWithString(url.to_s)
      fail(ArgumentError, "could not parse \"#{url}\" into NSURL") unless nsurl.host

      path = nsurl.path
      path = "/" if path == ""

      port = nsurl.port
      port = nsurl.scheme == "https" ? 443 : 80 unless port

      signature = [
        timestamp,
        nonce,
        verb.to_s.upcase,
        path,
        nsurl.host,
        port,
        "", nil
      ].join("\n")

      digest = CocoaSecurity.send(algorithm, signature, secret)
      digest.base64
    end

  private

    def generate_nonce
      timestamp = Time.now.utc.to_i
      uuid = CFUUIDCreate(nil)
      string = CFUUIDCreateString(nil, uuid)
      CocoaSecurity.md5([timestamp, string].join(":")).hex
    end
  end
end
