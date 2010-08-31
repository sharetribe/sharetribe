require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name           = "recaptcha"
    gem.description    = "This plugin adds helpers for the reCAPTCHA API "
    gem.summary        = "Helpers for the reCAPTCHA API"
    gem.homepage       = "http://ambethia.com/recaptcha"
    gem.authors        = ["Jason L. Perry"]
    gem.email          = "jasper@ambethia.com"
    gem.files.reject! { |fn| fn.include? ".gitignore" }
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rd|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rd.main = "README.rdoc"
  rd.rdoc_files.include "README.rdoc", "LICENSE", "lib/**/*.rb"
  rd.rdoc_dir = 'rdoc'
  rd.options << '-N' # line numbers
  rd.options << '-S' # inline source
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/*_test.rb'
  # test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :default => :test



