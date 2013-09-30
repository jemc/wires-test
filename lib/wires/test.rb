gem 'minitest', '~> 4.3.2'
require 'minitest/autorun'


module Wires
  
  module Test
    
    module Helper
      
      def self.build_alt(wires_module_path, affix:nil)
        affix = affix.to_s if affix
        
        [__FILE__]
          .map  { |file| File.read file }
          .each do |code| 
            code.gsub!("Wires", "#{wires_module_path}")
            instance_methods.each do |meth|
              meth     = meth.to_s
              sys_meth = meth
              sys_meth.gsub! /([^_]*)$/, "#{affix}_\1" if affix
              code.gsub!(meth, sys_meth)
            end
            eval code
          end
      end
      
      def before_setup
        @received_wires_events = []
        Channel.before_fire { |e,c| @received_wires_events << [e,c] }
        super
      end
      
      def after_teardown
        super
        clear_fired
      end
      
      def fired?(event,channel=self, 
                     clear:false, exclusive:false, plurality:nil,
                     exact_event:false, exact_channel:false)
        key_chan  = Channel[channel] unless channel.is_a? Channel
        key_event = Event.new_from event
        
        case key_event.count
        when 0
          raise ArgumentError,"Can't create an event from input: #{input.inspect}"
        when 1
          key_event = key_event.first
        else
          raise ArgumentError,"Can't check for fired? on multiple events: #{key_event.inspect}"
        end
        
        results = @received_wires_events.select { |e,c|
          (exact_event   ? (key_event.event_type == e.event_type) : (key_event =~ e)) and
          (exact_channel ? (key_chan  === c)                      : (key_chan  =~ c))
        }
        
        clear_fired if clear
        
        return false if results.empty?
        return false if exclusive and (@received_wires_events != results)
        return false if plurality and (results.size != plurality)
        
        # Execute passed block for each match
        results.each {|e,c| yield e,c if block_given?}
        
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
