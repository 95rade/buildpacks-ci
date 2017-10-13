#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'yaml'

version = "0.#{Time.now.to_i}"

Dir.chdir 'capi-release' do
  system(%(bosh --parallel 10 sync blobs && bosh create release --force --with-tarball --name capi --version #{version})) || raise('cannot create capi-release')
end

system('rsync -a capi-release/ capi-release-artifacts') || raise('cannot rsync directories')

File.write("capi-release-artifacts/use-capi-dev-release.yml", "---
- path: /releases/name=capi
  type: replace
  value:
    name: capi
    version: #{version}")
