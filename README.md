# MotionAuth-OAuth2

[![Build Status](https://travis-ci.org/motionauth/oauth2.svg)](https://travis-ci.org/motionauth/oauth2)
[![Code Climate](https://codeclimate.com/github/motionauth/oauth2/badges/gpa.svg)](https://codeclimate.com/github/motionauth/oauth2)

A [RubyMotion](http://www.rubymotion.com) fork of the existing
[OAuth2](https://github.com/intridea/oauth2) RubyGem that works for iOS and OS X.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "motion-oauth2"
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install motion-oauth2
```

## Usage Examples

```ruby
client = OAuth2::Client.new("client_id", "client_secret", site: "https://example.org")

client.auth_code.authorize_url(redirect_uri: "http://localhost:8080/oauth2/callback")
# => "https://example.org/oauth/authorization?response_type=code&client_id=client_id&redirect_uri=http://localhost:8080/oauth2/callback"

token = client.auth_code.get_token(
  "authorization_code_value",
  redirect_uri: "http://localhost:8080/oauth2/callback",
  headers:      { "Authorization" => "Basic some_password" }
)
response = token.get("/api/resource", params: { "query_foo" => "bar" })
response.class.name
# => OAuth2::Response
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
