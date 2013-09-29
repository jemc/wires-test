Gem::Specification.new do |s|
  s.name          = 'wires-test'
  s.version       = '0.0.4'
  s.date          = '2013-09-29'
  s.summary       = "wires-test"
  s.description   = "Testing convenience gem for the wires framework."
  s.authors       = ["Joe McIlvain"]
  s.email         = 'joe.eli.mac@gmail.com'
  
  s.files         = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  
  s.require_path  = 'lib'
  s.homepage      = 'https://github.com/jemc/wires-test/'
  s.licenses      = "Copyright (c) Joe McIlvain. All rights reserved "
  
  s.add_dependency('wires', '~> 0.4.0')
  s.add_dependency('minitest', '~> 4.3.2')
  
  s.add_development_dependency('rake')
  s.add_development_dependency('jemc-reporter')
end