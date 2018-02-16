#!/usr/bin/env ruby

require 'yaml'

#See https://github.com/cloudfoundry/bosh-deployment-resource#dynamic-source-configuration

target_config = {}

`wget https://github.com/cloudfoundry/bosh-bootloader/releases/download/v5.11.5/bbl-v5.11.5_linux_x86-64`
`chmod 755 bbl-v5.11.5_linux_x86-64`
BBL = "#{Dir.pwd}/bbl-v5.11.5_linux_x86-64"

Dir.chdir("bbl-state/#{ENV['ENV_NAME']}") do
  target_config = {
    "target"=> `#{BBL} director-address`.strip,
    "client_secret"=> `#{BBL} director-password`.strip,
    "client"=> `#{BBL} director-username`.strip,
    "ca_cert"=> `#{BBL} director-ca-cert`.strip
  }
end

File.write("deployment-source-config/source_file.yml", YAML.dump(target_config))
