#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'yaml'

version = "0.#{Time.now.to_i}"
bal_develop_sha = nil

Dir.chdir 'bal-develop' do
  bal_develop_sha = `git rev-parse HEAD`.chomp
end

Dir.chdir 'diego-release' do
  Dir.chdir 'src/code.cloudfoundry.org/buildpackapplifecycle' do
    system(%(git fetch && git checkout "#{bal_develop_sha}")) || raise('could not update buildpackapplifecycle in diego-release')
  end

  FileUtils.mkdir_p 'src/github.com/cloudfoundry-incubator'
  Dir.chdir 'src/github.com/cloudfoundry-incubator' do
    system(%(git clone https://github.com/cloudfoundry-incubator/credhub-cli.git))
  end

  %w(buildpack_app_lifecycle windows_app_lifecycle).each do |name|
    spec = YAML.load_file("packages/#{name}/spec")
    spec['files'] << 'code.cloudfoundry.org/buildpackapplifecycle/*/*.go'
    spec['files'] << 'github.com/cloudfoundry-incubator/credhub-cli/**/*.go'
    File.write("packages/#{name}/spec", spec.to_yaml)
  end

  system(%(bosh --parallel 10 sync blobs && bosh create release --force --with-tarball --name diego --version #{version})) || raise('cannot create diego-release')
end

system('rsync -a diego-release/ diego-release-artifacts') || raise('cannot rsync directories')

File.write("diego-release-artifacts/use-diego-dev-release.yml", "---
- path: /releases/name=diego
  type: replace
  value:
    name: diego
    version: #{version}")
