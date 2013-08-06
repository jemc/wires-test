gem 'minitest', '~> 4.3'
require 'minitest/autorun'


module Wires
  
  def self.test_format
    require 'turn'
    Turn.config.format  = :outline
    Turn.config.natural = true
    Turn.config.trace   = 5
  end
  
  # module TestModule
    
  #   def before_setup
  #     @received_wires_events = []
  #     on :event do |e|
  #       @received_wires_events << e
  #     end
      
  #     Hub.run
  #     super
  #   end
    
  #   def after_teardown
  #     super
  #     Hub.kill
      
  #     @received_wires_events.clear
  #   end
    
  #   def assert_fired event
  #     e = Event.new_from event
  #     assert (@received_wires_events.include? e),
  #       "Expected #{event.inspect} event to have been fired."
  #   end
    
  # end
  
  # class Test < Minitest::Test;  include TestModule;  end
  # class Spec < Minitest::Spec;  include TestModule;  end
  
end
