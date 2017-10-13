#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'yaml'

version = "0.#{Time.now.to_i}"

Dir.chdir 'capi-release' do
  system(%(bosh2 sync-blobs --parallel=10 && bosh2 create-release --force --tarball=dev_releases/capi/capi-#{version}.tgz --name=capi --version=#{version})) || raise('cannot create capi-release')
end

system('rsync -a capi-release/ capi-release-artifacts') || raise('cannot rsync directories')

File.write("capi-release-artifacts/use-capi-dev-release.yml", "---
- path: /releases/name=capi
  type: replace
  value:
    name: capi
    version: #{version}")
