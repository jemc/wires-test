
module Wires
  module Test
    module Helper
      
      def before_setup
        @received_wires_events = []
        Channel.add_hook(:@before_fire) { |e,c| 
          @received_wires_events << [e,c]
        }
      end
      
      def after_teardown
        clear_fired
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
        
        results = @received_wires_events.select { |e,c|
          (exact_event   ? (key_event.event_type == e.event_type) : (key_event =~ e)) and
          (exact_channel ? (key_chan  === c)                      : (key_chan  =~ c))
        }
        
        clear_fired if clear
        
        return false if results.empty?
        return false if exclusive and (@received_wires_events != results)
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
        @received_wires_events.clear
      end
    end
      
    # Build an alternate version of Test for an alternate Wires module
    # Optionally, specify an affix to be used in method names;
    # This helps to differentiate from the original Helper
    def self.build_alt(wires_module_path, affix:nil)
      affix = affix.to_s if affix
      
      [__FILE__] # List of files to mutate and eval
        .map  { |file| File.read file }
        .each do |code|
          
          code.gsub!(/Wires/, "#{wires_module_path}")
          
          mutated_names = 
            Helper.instance_methods \
            - [:before_setup, :after_teardown] \
            + [:@received_wires_events]
          
          mutated_names.each do |meth|
            meth     = meth.to_s
            sys_meth = meth.gsub /([^_]+)$/, "#{affix}_\\1"
            code.gsub!(meth, sys_meth)
          end if affix
          
          eval code
        end
    end
  end
end


# def with_stimulus(event)
  shared_context "with wires stimulus" do |event|
    around do |example|
      extend Wires::Test::Helper
      
      before_setup
      Wires::Channel[subject].fire! event
      # example.extend Wires::Test::Helper
      example.run
      after_teardown
    end
    
    # yield
  end
# end
