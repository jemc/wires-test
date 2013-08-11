gem 'minitest', '~> 4.3'
require 'minitest/autorun'


module Wires
  
  module Test
    
    module Helper
    
      def before_setup
        @received_wires_events = []
        Channel.before_fire { |e,c| @received_wires_events << [e,c] }
        Hub.run
        super
      end
      
      def after_teardown
        super
        Hub.kill
        @received_wires_events.clear
      end
      
      def fired?(event, channel='*', clear:false, exclusive:false, 
                 id_exact:false, channel_exact:false, &block)
        key_event = Event.new_from event
        key_chan  = Channel.new channel
        
        results = @received_wires_events.select { |e,c|
          (id_exact      ? (key_event === e) : (key_event =~ e)) and
          (channel_exact ? (key_chan  === c) : (key_chan  =~ c))
        }
        
        clear_fired if clear
        
        return false if results.empty?
        return false if exclusive and (@received_wires_events.size != 1)
        return false if exclusive and (results.size != 1)
        
        results.each(&block) # Execute passed block for each match
        
        true
      end
      
      def assert_fired(event, channel='*', assert_string=nil, **options, &block)
        assert fired?(event, channel, **options, &block), assert_string||\
          "Expected an event matching #{event.inspect}"\
          " to have been fired on channel #{channel.inspect}."
      end
      
      def refute_fired(event, channel='*', assert_string=nil, **options, &block)
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
