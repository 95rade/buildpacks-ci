#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'yaml'

version = "0.#{Time.now.to_i}"

bal_develop_sha = nil
Dir.chdir 'bal-develop' do
  bal_develop_sha = `git rev-parse HEAD`.chomp
end

Dir.chdir 'capi-release' do
  Dir.chdir 'src/code.cloudfoundry.org/buildpackapplifecycle' do
    system(%(git fetch && git checkout "#{bal_develop_sha}")) || raise('could not update buildpackapplifecycle in capi-release')
  end
  system(%(bosh2 sync-blobs --parallel=10 && bosh2 create-release --force --tarball=dev_releases/capi/capi-#{version}.tgz --name=capi --version=#{version})) || raise('cannot create capi-release')
end

system('rsync -a capi-release/ capi-release-artifacts') || raise('cannot rsync directories')

File.write("capi-release-artifacts/use-capi-dev-release.yml", "---
- path: /releases/name=capi
  type: replace
  value:
    name: capi
    version: #{version}")
