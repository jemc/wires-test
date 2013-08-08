Gem::Specification.new do |s|
  s.name          = 'wires-test'
  s.version       = '0.0.1'
  s.date          = '2013-08-05'
  s.summary       = "wires-test"
  s.description   = "Testing convenience gem for the wires framework."
  s.authors       = ["Joe McIlvain"]
  s.email         = 'joe.eli.mac@gmail.com'
  
  s.files         = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  
  s.require_path  = 'lib'
  s.homepage      = 'https://github.com/jemc/wires/'
  s.licenses      = "Copyright (c) Joe McIlvain. All rights reserved "
  
  s.add_dependency('wires')
  
  s.add_development_dependency('rake')
  s.add_development_dependency('minitest', '~> 4.3')
  s.add_development_dependency('minitest-reporters')
  s.add_development_dependency('turn')
end