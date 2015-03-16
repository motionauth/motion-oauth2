describe OAuth2::Strategy::Base do
  it "initializes with a Client" do
    -> { OAuth2::Strategy::Base.new(OAuth2::Client.new("abc", "def")) }.should.not.raise(StandardError)
  end
end
