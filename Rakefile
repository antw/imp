require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "imp"
    gem.summary = %Q{A Sinatra-like DSL for creating command-line Ruby apps.}
    gem.email = "anthony@ninecraft.com"
    gem.homepage = "http://github.com/antw/imp"
    gem.authors = ["Anthony Williams"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings

    gem.add_dependency 'extlib', '>= 0.9'
    gem.add_development_dependency 'rspec', '>= 1.2'
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

# Specs & Examples ===========================================================

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_opts  = ["-cfs"]
  spec.spec_files = begin
    if ENV["TASK"]
      ENV["TASK"].split(',').map { |task| "spec/**/#{task}_spec.rb" }
    else
      FileList['spec/**/*_spec.rb']
    end
  end
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)
rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end

task :default => :spec

# Documentation ==============================================================

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run YARD documentation, you must first install yardoc"
  end
end

begin
  require 'hanna/rdoctask'
rescue LoadError
  require 'rake/rdoctask'
end

Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "imp #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

