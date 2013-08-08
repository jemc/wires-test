$LOAD_PATH.unshift(File.expand_path("../lib", File.dirname(__FILE__)))
require 'wires'

require 'wires/test'
# Wires.test_format


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
      clear_fired; fire :event
      assert fired?     :event
      assert fired?     :event, 'channel'
      assert fired?     :event, 'channel2'
      
      clear_fired; fire :event, 'channel'
      assert fired?     :event
      assert fired?     :event, 'channel'
      refute fired?     :event, 'channel2'
      
      clear_fired; fire :some
      assert fired?     :event
      assert fired?     :some
      refute fired?     :some_other
      assert fired?     Wires::Event
      assert fired?     SomeEvent
      refute fired?     SomeOtherEvent
      assert fired?     Wires::Event.new
      assert fired?     SomeEvent.new
      refute fired?     SomeOtherEvent.new
      
      clear_fired; fire :event, 'channel'
      assert fired?     :event, /han/
      refute fired?     :event, /^han/
      assert fired?     :event, /(ch|fl)an+e_*l$/
      refute fired?     :event, /(pl|fl)an+e_*l$/
      
    end
    
    it "doesn't" do
      assert nil
    end
    it "does" do
      assert 1
    end
    it "does" do
      assert 1
    end
    it "does" do
      assert 1
    end
    it "does" do
      assert 1
    end
    it "does" do
      assert 1
    end
    it "does" do
      assert 1
    end
    it "does" do
      assert 1
    end
    it "does" do
      assert 1
    end
    it "does" do
      assert 1
    end
    it "does" do
      assert 1
    end
    it "does" do
      assert 1
    end
    it "does" do
      asserfeit 1
    end
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
