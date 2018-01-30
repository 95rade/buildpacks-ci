require "json"
require "http/client"

module Depwatcher
  module Rubygems
    class External
      JSON.mapping(
        number: String,
        sha: String,
        prerelease: Bool,
      )
    end
    class Internal
      JSON.mapping(
        ref: String,
        sha256: String,
      )
      def initialize(external : External)
        @ref = external.number
        @sha256 = external.sha
      end
    end

    def self.check(name : String) : Array(Internal)
      #ctx = OpenSSL::SSL::Context::Client.new()
      #ctx.ca_certificates_path = "/etc/ssl/certs"
      #client = HTTP::Client.new("rubygems.org", 443, ctx)
      #response = client.get "/api/v1/versions/#{name}.json"

      response = Depwatcher.client("rubygems.org").get "/api/v1/versions/#{name}.json"
      raise "Could not download data from rubygems: code #{response.status_code}" unless response.status_code == 200
      Array(External).from_json(response.body).reject do |r|
        r.prerelease
      end.map do |r|
        Internal.new(r)
      end.first(10).reverse
    end
  end
end
