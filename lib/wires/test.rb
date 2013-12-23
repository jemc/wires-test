
# Encase all code in a HEREDOC string until the...
<<'-END OF IMPLEMENTATION'

module Wires
  module Test
    module Helper
      
      attr_reader :AFFIX_wires_events
      
      def AFFIX_wires_test_setup
        @AFFIX_wires_events = []
        @AFFIX_wires_test_fire_hook = \
        Channel.add_hook(:@before_fire) { |e,c| 
          @AFFIX_wires_events << [e,c]
        }
      end
      
      def AFFIX_wires_test_teardown
        Wires::Hub.join_children
        @AFFIX_wires_events = nil
        Channel.remove_hook(:@before_fire, &@AFFIX_wires_test_fire_hook)
      end
      
      def AFFIX_fired?(event, channel=:__no_channel_was_specified__, 
                 clear:false, exclusive:false, plurality:nil,
                 exact_event:false, exact_channel:false,
                 &block)
        key_chan = 
          case channel
          when :__no_channel_was_specified__
            nil
          when Channel
            channel
          else
            Channel[channel]
          end
        
        key_event = Event.list_from event
        
        case key_event.count
        when 0
          raise ArgumentError,"Can't create an event from input: "\
                              "#{event.inspect}"
        when 1
          key_event = key_event.first
        else
          raise ArgumentError,"Can't check for fired? on multiple events: "\
                              "#{key_event.inspect}"
        end
        
        results = @AFFIX_wires_events.select { |e,c|
          c = Channel[c]
          (exact_event   ? (key_event == e) : (key_event =~ e)) && (!key_chan ||
          (exact_channel ? (key_chan  == c) : (key_chan  =~ c)))
        }
        
        # If passed a block, use it to determine
        results.select! { |e,c| yield e,c } if block_given?
        
        clear_AFFIX_fired if clear
        
        return false if results.empty?
        return false if exclusive and (@AFFIX_wires_events != results)
        return false if plurality and (results.size != plurality)
        
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


shared_context "with AFFIX wires", :AFFIX_wires=>true do
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
  
  extend Wires::Test::RSpec::ExampleGroupMethods
end

shared_context "with AFFIX wires stimulus" do |event, **kwargs|
  include_context "with AFFIX wires"
  
  before do
    channel_obj = AFFIX_wires_test_channel_from_kwargs **kwargs
    channel_obj.fire event, blocking:true
  end
end


::RSpec::Matchers.define :have_AFFIX_fired do
  match do |_|
    *args, fulfilling = process_expected(*expected)
    AFFIX_fired? *args, &fulfilling
  end
  
  description do
    event, channel, _ = process_expected(*expected)
    
    str = "have fired #{event.inspect}"
    str += " on #{channel.inspect}" if channel
    str
  end
  
  failure_message_for_should do |*args, &blk|
    "received: \n  #{actual_events.map(&:inspect).join("\n  ")}"
  end
  
  failure_message_for_should_not do |*args, &blk|
    "received: \n  #{actual_events.map(&:inspect).join("\n  ")}"
  end
  
  def actual_events
    matcher_execution_context.instance_variable_get :@AFFIX_wires_events
  end
  
  def process_expected(*args, fulfilling:nil); [*args, fulfilling] end
end


module Wires
  module Test
    module RSpec
      module ExampleGroupMethods
      
        def with_AFFIX_stimulus(event, **kwargs, &block)
          context "(with AFFIX stimulus #{event.inspect})" do
            include_context "with AFFIX wires stimulus", event, **kwargs
            instance_eval &block
          end
        end
        
        def it_AFFIX_fires(event, **kwargs, &block)
          context "fires #{event.inspect}" do
            specify do
              channel_obj = AFFIX_wires_test_channel_from_kwargs **kwargs
              should have_AFFIX_fired event, channel_obj, fulfilling:block
            end
          end
        end
        
        def it_AFFIX_fires_no(event, **kwargs, &block)
          context "fires no #{event.inspect}" do
            specify do
              channel_obj = AFFIX_wires_test_channel_from_kwargs **kwargs
              should_not have_AFFIX_fired event, channel_obj, fulfilling:block
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



module Wires
  module Test
    # Build an alternate version of Test for an alternate Wires module
    # Optionally, specify an affix to be used in method names;
    # This helps to differentiate from the original Helper
    def self.build_alt(wires_module_path, affix:nil)
      affix = affix ? affix.to_s+'_' : ''
      
      [__FILE__] # List of files to mutate and eval
        .map  { |file| File.read file }
        .each do |code|
          
          code =~ /(?<='-END OF IMPLEMENTATION').*?(?=-END OF IMPLEMENTATION)/m
          code = $&

          code.gsub! /Wires/, "#{wires_module_path}"
          code.gsub! /AFFIX[_ ]/, affix
          
          eval code
        end
    end
  end
end