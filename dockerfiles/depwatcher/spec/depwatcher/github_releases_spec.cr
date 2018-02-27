require "spec"
require "../../src/depwatcher/github_releases"

class HTTPClientTest < Depwatcher::HTTPClient
  @stubs = Hash(String, String).new

  def get(url)
    @stubs[url] || raise "url(#{url}) was not stubbed"
  end

  def stub_get(url, res)
    @stubs[url] = res
  end
end

describe Depwatcher::GithubReleases do
  describe "#check" do
    it "returns real releases sorted" do
      subject = Depwatcher::GithubReleases.new
      client = HTTPClientTest.new
      subject.client = client
      client.stub_get("https://api.github.com/repos/yarnpkg/yarn/releases", File.read(__DIR__+"/../fixtures/yarn.json"))

      subject.check("yarnpkg/yarn").map(&.ref).should eq [
        "0.24.6", "0.25.3", "0.25.4", "0.26.0", "0.26.1", "0.27.0", "0.27.1",
        "0.27.2", "0.27.3", "0.27.4", "0.27.5", "1.0.0 ! 🎉", "1.0.1", "1.0.2", "1.1.0",
        "1.1.0-exp.2", "1.2.0", "1.2.1", "1.3.0", "1.3.1", "1.3.2"
      ]
    end
  end

  describe "#in" do
    it "returns real releases sorted" do
      subject = Depwatcher::GithubReleases.new
      client = HTTPClientTest.new
      subject.client = client
      client.stub_get("https://api.github.com/repos/yarnpkg/yarn/releases", File.read(__DIR__+"/../fixtures/yarn.json"))

      subject.check("yarnpkg/yarn").map(&.ref).should eq [
        "0.24.6", "0.25.3", "0.25.4", "0.26.0", "0.26.1", "0.27.0", "0.27.1",
        "0.27.2", "0.27.3", "0.27.4", "0.27.5", "1.0.0 ! 🎉", "1.0.1", "1.0.2", "1.1.0",
        "1.1.0-exp.2", "1.2.0", "1.2.1", "1.3.0", "1.3.1", "1.3.2"
      ]
    end
  end
end
