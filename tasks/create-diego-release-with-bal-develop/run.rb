#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'yaml'

bal_develop_sha = nil

Dir.chdir 'bal-develop' do
  bal_develop_sha = `git rev-parse HEAD`
end

Dir.chdir 'diego-release' do
  Dir.chdir 'src/code.cloudfoundry.org/buildpackapplifecycle' do
    system(%(git checkout "#{bal_develop_sha}"))
  end
  system(%(bosh --parallel 10 sync blobs && bosh create release --force --with-tarball --name diego --version 0.#{Time.now.to_i})) || raise('cannot create diego-release')
end

system('rsync -a diego-release/ diego-release-artifacts') || raise('cannot rsync directories')
