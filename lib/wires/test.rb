
module Wires
  module Test
    module Helper
      
      def wires_test_setup
        @wires_events = []
        @wires_test_fire_hook = \
        Channel.add_hook(:@before_fire) { |e,c| 
          @wires_events << [e,c]
        }
      end
      
      def wires_test_teardown
        @wires_events = nil
        Channel.remove_hook(:@before_fire, &@wires_test_fire_hook)
      end
      
      def fired?(event, channel=self, 
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
        
        results = @wires_events.select { |e,c|
          (exact_event   ? (key_event.event_type == e.event_type) : (key_event =~ e)) and
          (exact_channel ? (key_chan  === c)                      : (key_chan  =~ c))
        }
        
        clear_fired if clear
        
        return false if results.empty?
        return false if exclusive and (@wires_events != results)
        return false if plurality and (results.size != plurality)
        
        # Execute passed block for each match
        results.each { |e,c| yield e,c if block_given? }
        
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
        @wires_events.clear
      end
    end
      
    # # Build an alternate version of Test for an alternate Wires module
    # # Optionally, specify an affix to be used in method names;
    # # This helps to differentiate from the original Helper
    # def self.build_alt(wires_module_path, affix:nil)
    #   affix = affix.to_s if affix
      
    #   [__FILE__] # List of files to mutate and eval
    #     .map  { |file| File.read file }
    #     .each do |code|
          
    #       code.gsub!(/Wires/, "#{wires_module_path}")
          
    #       mutated_names = 
    #         Helper.instance_methods \
    #         - [:wires_test_setup, :wires_test_teardown] \
    #         + [:@received_wires_events]
          
    #       mutated_names.each do |meth|
    #         meth     = meth.to_s
    #         sys_meth = meth.gsub /([^_]+)$/, "#{affix}_\\1"
    #         code.gsub!(meth, sys_meth)
    #       end if affix
          
    #       eval code
    #     end
    # end
  end
end


shared_context "with Wires stimulus" do |event|
  around do |example|
    receiver = subject
    
    example.extend Wires::Test::Helper
    example.wires_test_setup
    
    Wires::Channel[receiver].fire! event
    example.run
    
    example.wires_test_teardown
  end
end


module Wires
  module Test
    module RSpec
      module ExampleGroupMethods
      
        def with_stimulus(event, &block)
          context "(with stimulus #{event.inspect})" do
            include_context "with Wires stimulus", event
            instance_eval &block
          end
        end
        
      end
    end
  end
end


RSpec.configuration.extend Wires::Test::RSpec::ExampleGroupMethods
