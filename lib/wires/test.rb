gem 'minitest', '~> 4.3'
require 'minitest/autorun'


module Wires
  
  def self.test_format
    require 'turn'
    Turn.config.format  = :outline
    Turn.config.natural = true
    Turn.config.trace   = 5
  end
  
end
