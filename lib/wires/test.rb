gem 'minitest', '~> 4.3.2'
require 'minitest/autorun'


module Wires
  
  module Test
    
    module Helper
    
      def before_setup
        @received_wires_events = []
        Channel.before_fire { |e,c| @received_wires_events << [e,c] }
        super
      end
      
      def after_teardown
        super
        clear_fired
      end
      
      def fired?(event,channel=self, clear:false, exclusive:false, plurality:nil,
                 exact_event:false, exact_channel:false, &block)
        key_event = Event.new_from event
        key_chan  = Channel[channel] unless channel.is_a? Channel
        
        results = @received_wires_events.select { |e,c|
          (exact_event   ? (key_event.class == e.class) : (key_event =~ e)) and
          (exact_channel ? (key_chan  === c)            : (key_chan  =~ c))
        }
        
        clear_fired if clear
        
        return false if results.empty?
        return false if exclusive and (@received_wires_events != results)
        return false if plurality  and (results.size != plurality)
        
        results.each(&block) # Execute passed block for each match
        
        true
      end
      
      def assert_fired(event, channel=self, assert_string=nil, **options, &block)
        assert fired?(event, channel, **options, &block), assert_string||\
          "Expected an event matching #{event.inspect}"\
          " to have been fired on channel #{channel.inspect}."
      end
      
      def refute_fired(event, channel=self, assert_string=nil, **options, &block)
        refute fired?(event, channel, **options, &block), assert_string||\
          "Expected no events matching #{event.inspect}"\
          " to have been fired on channel #{channel.inspect}."
      end
      
      def clear_fired
        @received_wires_events.clear
      end
    end
  
    class Unit < Minitest::Unit;  include Test::Helper;  end
    class Spec < Minitest::Spec;  include Test::Helper;  end
  end
  
end
