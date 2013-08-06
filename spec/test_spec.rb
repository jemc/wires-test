$LOAD_PATH.unshift(File.expand_path("../lib", File.dirname(__FILE__)))
require 'wires'

require 'wires/test'
Wires.test_format


module Wires
  
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



class SomeEvent < Wires::Event; end

def foo &block
  Thread.new do block.call end
end

describe nil do
  it "" do
    p self
    # 1.must_equal 1
    on SomeEvent do
      # p Minitest::Spec.current
    #   p self
    #   1.must_equal 1
    end
    
    Thread.new do
      p Minitest::Spec.current
    end
    # pr.call
    
    # p Minitest::Spec.current
    
    Wires::Hub.run
    fire SomeEvent
    Wires::Hub.kill
  end
end







# class SomeEvent < Wires::Event; end

# class MyTest < Wires::Test
  
#   def test_something
#     p @received_wires_events
#     puts self.class.superclass
#     fire SomeEvent
#     p @received_wires_events
    
#     p @received_wires_events.object_id
#     # assert_fired :some
#   end
# end

# class MySpec < Wires::Spec
#   it "nil" do
#     puts @received_wires_events
#     puts self.class.superclass
#   end
# end
