require 'rake/testtask'

gemname = 'wires-test'

task :default => [:test]

# Run tests
Rake::TestTask.new :test do |t|
  t.test_files = Dir['test/*.rb','spec/*.rb']
end

# Rebuild gem
task :g do exec "
rm #{gemname}*.gem
gem build #{gemname}.gemspec
gem install #{gemname}*.gem" end

# Rebuild and push gem
task :gp do exec "
rm #{gemname}*.gem
gem build #{gemname}.gemspec
gem install #{gemname}*.gem
gem push #{gemname}*.gem" end

