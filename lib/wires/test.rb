
module Wires
  module Test
    module Helper
      
      attr_reader :wires_events
      
      def wires_test_setup
        @wires_events = []
        @wires_test_fire_hook = \
        Channel.add_hook(:@before_fire) { |e,c| 
          @wires_events << [e,c]
        }
      end
      
      def wires_test_teardown
        Wires::Hub.join_children
        @wires_events = nil
        Channel.remove_hook(:@before_fire, &@wires_test_fire_hook)
      end
      
      def fired?(event, channel=:__no_channel_was_specified__, 
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
        
        results = @wires_events.select { |e,c|
          c = Channel[c]
          (exact_event   ? (key_event == e) : (key_event =~ e)) && (!key_chan ||
          (exact_channel ? (key_chan  == c) : (key_chan  =~ c)))
        }
        
        # If passed a block, use it to determine
        results.select! { |e,c| yield e,c } if block_given?
        
        clear_fired if clear
        
        return false if results.empty?
        return false if exclusive and (@wires_events != results)
        return false if plurality and (results.size != plurality)
        
        true
      end
      
      def clear_fired
        @wires_events.clear
      end
      
      def wires_test_channel_from_kwargs **kwargs
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


shared_context "with wires", :wires=>true do
  unless ancestors.include? Wires::Convenience
    include Wires::Convenience
  end
  
  unless ancestors.include? Wires::Test::Helper
    include Wires::Test::Helper
    around do |example|
      wires_test_setup
      example.run
      wires_test_teardown
    end
  end
  
  extend Wires::Test::RSpec::ExampleGroupMethods
end

shared_context "with wires stimulus" do |event, **kwargs|
  include_context "with wires"
  
  before do
    channel_obj = wires_test_channel_from_kwargs **kwargs
    channel_obj.fire event, blocking:true
  end
end


::RSpec::Matchers.define :have_fired do
  match do |_|
    *args, fulfilling = process_expected(*expected)
    fired? *args, &fulfilling
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
    matcher_execution_context.instance_variable_get :@wires_events
  end
  
  def process_expected(*args, fulfilling:nil); [*args, fulfilling] end
end


module Wires
  module Test
    module RSpec
      module ExampleGroupMethods
      
        def with_stimulus(event, **kwargs, &block)
          context "(with stimulus #{event.inspect})" do
            include_context "with wires stimulus", event, **kwargs
            instance_eval &block
          end
        end
        
        def it_fires(event, **kwargs, &block)
          context "fires #{event.inspect}" do
            specify do
              channel_obj = wires_test_channel_from_kwargs **kwargs
              should have_fired event, channel_obj, fulfilling:block
            end
          end
        end
        
        def it_fires_no(event, **kwargs, &block)
          context "fires no #{event.inspect}" do
            specify do
              channel_obj = wires_test_channel_from_kwargs **kwargs
              should_not have_fired event, channel_obj, fulfilling:block
            end
          end
        end
        
      end
    end
  end
end
