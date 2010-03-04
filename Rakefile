require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end
task :default => :test

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "asset_bundler"
    gemspec.summary = "A simple asset bundling solution."
    gemspec.description = "Adapted from asset bundling functionality in ActionPack."
    gemspec.email = "gbuesing@gmail.com"
    gemspec.homepage = "http://github.com/gbuesing/asset_bundler"
    gemspec.authors = ["Geoff Buesing"]
    gemspec.add_dependency('asset_timestamps_cache', '>= 0.1.1')
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
