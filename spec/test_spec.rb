$LOAD_PATH.unshift(File.expand_path("../lib", File.dirname(__FILE__)))
require 'wires'

require 'wires/test'
require 'wires/test-reporter'


class SomeEvent      < Wires::Event; end
class SomeOtherEvent < SomeEvent;    end


describe Wires::Test::Helper do
  
  include Wires::Test::Helper
  
  it 'tracks all events fired in each test' do
    @received_wires_events.must_equal []
    
    fire :event
    @received_wires_events.size.must_equal 1
    event, chan = @received_wires_events[0]
    event.must_be_instance_of Wires::Event
    chan .must_be_instance_of Wires::Channel
    
    20.times do fire :event end
    @received_wires_events.size.must_equal 21
    
    fire :some; fire :some
    @received_wires_events.size.must_equal 23
    @received_wires_events.select{|x| x[0].is_a? SomeEvent}
                          .size.must_equal 2
    
    fire :event, 'some_channel'
    fire :event, 'some_channel'
    @received_wires_events.size.must_equal 25
    @received_wires_events.select{|x| x[1]==Wires::Channel.new('some_channel')}
                          .size.must_equal 2
  end
  
  it 'will not remember events from other tests' do
    @received_wires_events.must_equal []
    fire :event
    @received_wires_events.size.must_equal 1
  end
  
  it 'will remember events if the Hub is killed/run inside the test' do
    @received_wires_events.must_equal []
    fire :event
    @received_wires_events.size.must_equal 1
    
    Wires::Hub.kill; Wires::Hub.run
    @received_wires_events.size.must_equal 1
  end
  
  describe '00 #clear_fired' do
    it "clears the list of stored event/channel pairs" do
      @received_wires_events.must_equal []      
      fire :event
      @received_wires_events.size.must_equal 1
      clear_fired
      @received_wires_events.size.must_equal 0
      20.times { fire :event }
      @received_wires_events.size.must_equal 20
      clear_fired
      @received_wires_events.size.must_equal 0
    end
  end
  
  describe '01 #fired?' do
    it "can be used to match against the stored list" do
      fire :event
      assert fired?     :event
      assert fired?     :event, 'channel'
      assert fired?     :event, 'channel2'
      
      clear_fired; fire :event, 'channel'
      assert fired?     :event
      assert fired?     :event, 'channel'
      refute fired?     :event, 'channel2'
    end
    
    it "matches event subclasses by default" do
      fire :some
      assert fired?  :event
      assert fired?  :some
      refute fired?  :some_other
      assert fired?  Wires::Event
      assert fired?  SomeEvent
      refute fired?  SomeOtherEvent
      assert fired?  Wires::Event.new
      assert fired?  SomeEvent.new
      refute fired?  SomeOtherEvent.new
    end
    
    it "can match an exact event class instead of including subclasses" do
      fire :some
      refute fired?  :event,             exact_event:true
      assert fired?  :some,              exact_event:true
      refute fired?  :some_other,        exact_event:true
      refute fired?  Wires::Event,       exact_event:true
      assert fired?  SomeEvent,          exact_event:true
      refute fired?  SomeOtherEvent,     exact_event:true
      refute fired?  Wires::Event.new,   exact_event:true
      assert fired?  SomeEvent.new,      exact_event:true
      refute fired?  SomeOtherEvent.new, exact_event:true
    end
    
    it "matches all channels for which the key channel is relevant" do
      fire           :event, 'channel'
      assert fired?  :event, /han/
      refute fired?  :event, /^han/
      assert fired?  :event, /(ch|fl)an+e_*l$/
      refute fired?  :event, /(pl|fl)an+e_*l$/
    end
    
    it "can match an exact channel instead of by relevance" do
      fire           :event, 'channel'
      assert fired?  :event, /han/
      refute fired?  :event, /^han/
      assert fired?  :event, /(ch|fl)an+e_*l$/
      refute fired?  :event, /(pl|fl)an+e_*l$/
    end
    
    it "can clear the list after checking for a match" do
      fire :some, 'chan'
      assert fired?  :some, 'chan', clear:true
      refute fired?  :some, 'chan'
    end
    
    it "can test that no non-matching events were fired" do
      fire :some, 'chan'
      assert fired? :some, 'chan', exclusive:true
      
      clear_fired
      fire :some, 'chan'
      fire :some, 'chan'
      assert fired? :some, 'chan', exclusive:true
      
      clear_fired
      fire :some, 'chan'
      fire :some, 'chan2'
      refute fired? :some, 'chan', exclusive:true
      
      clear_fired
      fire :event, 'chan'
      fire :some, 'chan'
      refute fired? :some, 'chan', exclusive:true
    end
    
    it "can test the plurality of matching events" do
      fire :some, 'chan'
      assert fired? :some, 'chan', plurality:1
      
      clear_fired
      fire :some, 'chan'
      fire :some, 'chan'
      assert fired? :some, 'chan', plurality:2
      refute fired? :some, 'chan', plurality:1
      refute fired? :some, 'chan', plurality:3
    end
    
    it "can match event parameters by array notation" do
      fire          [:some, 11, 22.2, :symbol, kwarg1:'one', kwarg2:2]
      
      assert fired? [:some, 11]
      assert fired? [:some, 11, 22.2]
      assert fired? [:some, 11, 22.2, :symbol]
      
      refute fired? [:some, 22.2]
      refute fired? [:some, :symbol]
      
      assert fired? [:some, kwarg1:'one']
      assert fired? [:some, kwarg1:'one', kwarg2:2]
      assert fired? [:some, kwarg2:2]
      
      assert fired? [:some, 11, kwarg1:'one']
      assert fired? [:some, 11, 22.2, kwarg1:'one', kwarg2:2]
      assert fired? [:some, 11, 22.2, :symbol, kwarg2:2]
      assert fired? [:some, 11, 22.2, :symbol, kwarg1:'one']
      assert fired? [:some, 11, 22.2, :symbol, kwarg1:'one', kwarg2:2]
      assert fired? [:some, 11, 22.2, :symbol, kwarg2:2]
      
      refute fired? [:some, kwarg3:'three']
    end
    
    it "can execute a given block on all matching events" do
      fire [:some, 10, 55, 33, 88], 'chan'
      count = 0
      fired? :some do |e,c|
        count += 1
        e.args.each {|i| assert i>=10}
      end
      refute count.zero?
    end
  end
  
  describe '02 #assert_fired' do
    it "passes all args (including &block) to #fired? and asserts the result" do
      fire [:some, 10, 55, 33, 88], 'chan'
      count = 0
      assert_fired :some, /^ch.n$/, exclusive:true do |e,c|
        count += 1
        e.args.each {|i| assert i>=10}
      end
      refute count.zero?
    end
  end
  
  describe '03 #refute_fired' do
    it "passes all args (including &block) to #fired? and refutes the result" do
      fire [:some, 10, 55, 33, 88], 'chan'
      count = 0
      refute_fired :some_other, /^ch.n$/, clear:true do |e,c|
        count += 1
        e.args.each {|i| assert i>=10}
      end
      refute_fired :some, /^ch.n$/ do |e,c|
        count += 1
        e.args.each {|i| assert i>=10}
      end
      assert count.zero?
    end
  end
end

