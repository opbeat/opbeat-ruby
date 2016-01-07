require 'rubygems/package_task'
gemspec = Gem::Specification.load(Dir['*.gemspec'].first)
Gem::PackageTask.new(gemspec).define

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end
task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new

task :mem_profile do
  require 'memory_profiler'
  $:.unshift Dir.pwd + '/lib'

  filename = "profile-#{Time.now.to_i}.txt"

  MemoryProfiler.report(allow_files: /opbeat/i) do
    require 'opbeat'
  end.pretty_print(to_file: filename)

  filename
end
