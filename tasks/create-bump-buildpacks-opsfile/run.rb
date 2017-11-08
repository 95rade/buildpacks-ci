#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'yaml'

replacements = []
Dir.glob("*-buildpack-bosh-io-release").each do |bosh_release|
  release_name = bosh_release.gsub("-bosh-io-release", "")

  replacements << {
    path: "/releases/name=#{release_name}"
    type: "replace"
    value: {
      name: release_name,
      version: File.read("#{bosh_release}/version").strip,
      sha1: File.read("#{bosh_release}/sha1").strip,
      url: File.read("#{bosh_release}/url").strip
    }
  }
end

replacements << {
    path: "/releases/name=cflinuxfs2"
    type: "replace"
    value: {
      name: cflinuxfs2,
      version: File.read("cflinuxfs2-bosh-release/version").strip,
      sha1: File.read("cflinuxfs2-bosh-release/sha1").strip,
      url: File.read("cflinuxfs2-bosh-release/url").strip
    }
}

File.open("bump-buildpacks-opsfile/opsfile.yml", 'w') {|f| f.write replacements.to_yaml }#

