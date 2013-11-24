require 'rspec/core/rake_task'

gemname = 'wires-test'

task :default => :spec

# Run tests
RSpec::Core::RakeTask.new :spec do |c|
  c.pattern = 'spec/**/*.spec.rb'
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

