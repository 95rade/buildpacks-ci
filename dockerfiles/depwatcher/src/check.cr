require "./depwatcher/*"
require "json"

data = JSON.parse(STDIN)
STDERR.puts data.to_json
source = data["source"]

case type = source["type"].to_s
when "github_releases"
  versions = Depwatcher::GithubReleases.new.check(source["repo"].to_s)
when "rubygems"
  versions = Depwatcher::Rubygems.new.check(source["name"].to_s)
when "rubygems_cli"
  versions = Depwatcher::RubygemsCli.new.check
when "pypi"
  versions = Depwatcher::Pypi.new.check(source["name"].to_s)
when "ruby_lang"
  versions = Depwatcher::RubyLang.new.check
when "python"
  versions = Depwatcher::Python.new.check
when "golang"
  versions = Depwatcher::Golang.new.check
when "rlang"
  versions = Depwatcher::Rlang.new.check
when "npm"
  versions = Depwatcher::Npm.new.check(source["name"].to_s)
when "nginx"
  versions = Depwatcher::Nginx.new.check
when "httpd"
  versions = Depwatcher::Httpd.new.check
when "ca_apm_agent"
  versions = Depwatcher::CaApmAgent.new.check
when "appd_agent"
  versions = Depwatcher::AppDynamicsAgent.new.check
else
  raise "Unkown type: #{source["type"]}"
end

version = data["version"]?
if version
  ref = SemanticVersion.new(version["ref"].to_s) rescue nil
  versions.reject! do |v|
    SemanticVersion.new(v.ref) < ref
  end if ref
end
puts versions.to_json
