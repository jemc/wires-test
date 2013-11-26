
# Encase all code in a HEREDOC string until the...
<<'-END OF IMPLEMENTATION'

module Wires
  module Test
    module Helper
      
      attr_reader :AFFIX_wires_events
      
      def AFFIX_wires_test_setup
        @AFFIX_wires_events = []
        @AFFIX_wires_test_fire_hook = \
        Channel.add_hook(:@AFFIX_before_fire) { |e,c| 
          @AFFIX_wires_events << [e,c]
        }
      end
      
      def AFFIX_wires_test_teardown
        Wires::Hub.join_children
        @AFFIX_wires_events = nil
        Channel.remove_hook(:@AFFIX_before_fire, &@AFFIX_wires_test_fire_hook)
      end
      
      def AFFIX_fired?(event, channel, 
                 clear:false, exclusive:false, plurality:nil,
                 exact_event:false, exact_channel:false,
                 &block)
        key_chan  = channel.is_a?(Channel) ? channel : Channel[channel]
        key_event = Event.list_from event
        
        case key_event.count
        when 0
          raise ArgumentError,"Can't create an event from input: #{input.inspect}"
        when 1
          key_event = key_event.first
        else
          raise ArgumentError,"Can't check for fired? on multiple events: #{key_event.inspect}"
        end
        
        results = @AFFIX_wires_events.select { |e,c|
          c = Channel[c]
          (exact_event   ? (key_event.event_type == e.event_type) : (key_event =~ e)) and
          (exact_channel ? (key_chan  === c)                      : (key_chan  =~ c))
        }
        
        results.select! { |e,c| yield e,c } if block_given?
        
        clear_AFFIX_fired if clear
        
        return false if results.empty?
        return false if exclusive and (@AFFIX_wires_events != results)
        return false if plurality and (results.size != plurality)
        
        # # Execute passed block for each match
        # results.each { |e,c| yield e,c if block_given? }
        
        true
      end
      
      def clear_AFFIX_fired
        @AFFIX_wires_events.clear
      end
      
      def AFFIX_wires_test_channel_from_kwargs **kwargs
        # Get channel_name from keyword arguments
        channel_name = \
          kwargs.has_key?(:channel_name) ?
            kwargs[:channel_name]        :
            kwargs.has_key?(:to)           ?
              eval(kwargs[:to].to_s)       :
              subject
        # Get channel object from channel_name or keyword argument :channel_obj
        channel_obj = \
          kwargs.has_key?(:channel_obj) ?
            kwargs[:channel_obj]        :
            Wires::Channel[channel_name]
      end
    end
  end
end


shared_context "with AFFIX Wires", :AFFIX_wires=>true do
  unless ancestors.include? Wires::Convenience
    include Wires::Convenience
  end
  
  unless ancestors.include? Wires::Test::Helper
    include Wires::Test::Helper
    around do |example|
      AFFIX_wires_test_setup
      example.run
      AFFIX_wires_test_teardown
    end
  end
end

shared_context "with AFFIX Wires stimulus" do |event, **kwargs|
  include_context "with AFFIX Wires"
  
  before do
    channel_obj = AFFIX_wires_test_channel_from_kwargs **kwargs
    channel_obj.fire event, blocking:true
  end
end


::RSpec::Matchers.define :have_AFFIX_fired do |event, channel=nil|
  match do |_|
    channel ||= subject
    AFFIX_fired? event, channel
  end
end


module Wires
  module Test
    module RSpec
      module ExampleGroupMethods
      
        def with_AFFIX_stimulus(event, **kwargs, &block)
          context "(with stimulus #{event.inspect})" do
            include_context "with AFFIX Wires stimulus", event, **kwargs
            instance_eval &block
          end
        end
        
        def it_AFFIX_fires(event, **kwargs, &block)
          context "fires #{event.inspect}" do
            specify do
              channel_obj = AFFIX_wires_test_channel_from_kwargs **kwargs
              expect(AFFIX_fired?(event, channel_obj, &block)).to be
            end
          end
        end
        
        def it_AFFIX_fires_no(event, **kwargs, &block)
          context "fires no #{event.inspect}" do
            specify do
              channel_obj = AFFIX_wires_test_channel_from_kwargs **kwargs
              expect(AFFIX_fired?(event, channel_obj, &block)).to_not be
            end
          end
        end
        
      end
    end
  end
end

-END OF IMPLEMENTATION
.gsub(/AFFIX[_ ]/, "")    # Remove all AFFIX markers (see Wires::Test.build_alt)
.tap { |code| eval code } # Eval the cleaned code in 


RSpec.configuration.extend Wires::Test::RSpec::ExampleGroupMethods


module Wires
  module Test
    # Build an alternate version of Test for an alternate Wires module
    # Optionally, specify an affix to be used in method names;
    # This helps to differentiate from the original Helper
    def self.build_alt(wires_module_path, affix:nil)
      affix = affix.to_s if affix
      
      [__FILE__] # List of files to mutate and eval
        .map  { |file| File.read file }
        .each do |code|
          
          code =~ /(?<='-END OF IMPLEMENTATION').*?(?=-END OF IMPLEMENTATION)/m
          code = $&

          code.gsub! /Wires/, "#{wires_module_path}"
          code.gsub! /AFFIX[_ ]/, affix.to_s if affix
          
          eval code
        end
    end
  end
end