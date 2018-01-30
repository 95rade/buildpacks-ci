module Depwatcher
  def self.client(host : String)
    ctx = OpenSSL::SSL::Context::Client.new()
    ctx.ca_certificates_path = "/etc/ssl/certs"
    HTTP::Client.new(host, 443, ctx)
  end
end
