Gem::Specification.new do |s|
  s.name          = 'wires-test'
  s.version       = '0.1.4'
  s.date          = '2014-01-26'
  s.summary       = "wires-test"
  s.description   = "Testing convenience gem for the wires framework."
  s.authors       = ["Joe McIlvain"]
  s.email         = 'joe.eli.mac@gmail.com'
  
  s.files         = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  
  s.require_path  = 'lib'
  s.homepage      = 'https://github.com/jemc/wires-test/'
  s.licenses      = "Copyright 2013 Joe McIlvain. All rights reserved."
  
  s.add_dependency('wires', '~> 0.5.0')
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'fivemat'
end