class Dependencies
  def initialize(dep, line, keep_master, dependencies, master_dependencies)
    @dep = dep
    @line = line
    @keep_master = keep_master
    @dependencies = dependencies
    @matching_deps = dependencies.select do |d|
      d['name'] == @dep['name'] && same_line?(d['version'])
    end
    @master_dependencies = master_dependencies
  end

  def switch
    return @dependencies unless latest?
    (@dependencies - @matching_deps + [@dep] + master_dependencies).sort_by do |d|
      version = Gem::Version.new(d['version']) rescue d['version']
      [ d['name'], version ]
    end
  end

  private

  def latest?
    @matching_deps.all? do |d|
      Gem::Version.new(@dep['version']) > Gem::Version.new(d['version'])
    end
  end

  def same_line?(version)
    case @line
    when 'major'
      Gem::Version.new(version).segments[0] == Gem::Version.new(@dep['version']).segments[0]
    when 'minor'
      Gem::Version.new(version).segments[0,2] == Gem::Version.new(@dep['version']).segments[0,2]
    when nil, ''
      true
    else
      raise "Unknown version line specifier: #{@line}"
    end
  end

  def master_dependencies
    return [] unless @keep_master == 'true'

    dep = @master_dependencies.select do |d|
      d['name'] == @dep['name'] && same_line?(d['version'])
    end.sort_by { |d| Gem::Version.new(d['version']) }.last
    [dep]
  end
end

# old_version = nil
# manifest['dependencies'].each do |dep|
#   next unless dep['name'] == name
#   raise "Found a second entry for #{name}" if old_version

#   old_version = dep['version']
#   dep['version'] = build['version']
#   dep['uri'] = build['url']
#   dep['sha256'] = build['sha256']
# end

# if Gem::Version.new(build['version']) < Gem::Version.new(old_version)
#   puts 'SKIP: Built version is older than current version in buildpack.'
#   exit 0
# end
