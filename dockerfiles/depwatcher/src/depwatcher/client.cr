module Depwatcher
  def self.client(host : String)
    ctx = OpenSSL::SSL::Context::Client.new()
    ctx.ca_certificates = "/etc/ssl/certs/ca-certificates.crt"
    HTTP::Client.new(host, 443, ctx)
  end

  def self.ssl_get(uri : URI)
    client(uri.host.to_s).get(uri.path.to_s)
  end

  def self.ssl_get(uri : String)
    ssl_get(URI.parse(uri))
  end
end
