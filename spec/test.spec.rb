
require 'wires'
require 'wires/test'

require 'spec_helper'


# class SomeEvent      < Wires::Event; end
# class SomeOtherEvent < SomeEvent;    end

class TestObject
  include Wires::Convenience
  
  attr_accessor :touched
  
  def initialize
    on(:touch)   { @touched = true }
    on(:tag)     { fire :tagback }
    on(:reverse) { |e| reverse *e.args }
  end
  
  def reverse(text)
    fire :message[text.reverse, original:text]
  end
  
end



describe TestObject do
  its(:touched) { should_not be }
  
  context "with explicit shared context include" do
    include_context "with Wires stimulus", :touch
    its(:touched) { should be }
  end
  
  # With implicit receiver Wires::Channel[subject]
  with_stimulus :touch do
    its(:touched) { should be }
  end
  
  # With explicit reciever symbol referencing var in example scope
  with_stimulus :touch, :to=>:subject do
    its(:touched) { should be }
  end
  
  # With explicit channel name in example group scope
  test_object1 = TestObject.new
  with_stimulus :touch, :channel=>test_object1 do
    subject { test_object1 }
    its(:touched) { should be }
  end
  
  # With explicit channel object in example group scope
  test_object2 = TestObject.new
  with_stimulus :touch, :channel_obj=>Wires::Channel[test_object2] do
    subject { test_object2 }
    its(:touched) { should be }
  end
  
  with_stimulus :tag do
    it_fires :tagback
  end
  
  with_stimulus :tag do
    it_fires :tagback, :to=>:subject
  end
  
  test_object3 = TestObject.new
  with_stimulus :tag,  :channel=>test_object3 do
    it_fires :tagback, :channel=>test_object3 
  end
  
  test_object4 = TestObject.new
  with_stimulus :tag,  :channel_obj=>Wires::Channel[test_object4] do
    it_fires :tagback, :channel_obj=>Wires::Channel[test_object4] 
  end
  
  with_stimulus :reverse['rats'] do
    it_fires :message['star']
  end
  
  with_stimulus :reverse['rats'] do
    it_fires :message['star'] do |e|
      e.original == 'rats'
    end
  end
  
  with_stimulus :reverse['rats'] do
    it_fires_no :message['starstruck']
  end
  
  with_stimulus :reverse['rats'] do
    it_fires_no :message['star'] do |e|
      e.original != 'rats'
    end
  end
  
  with_stimulus :reverse['rats'] do
    it { should have_fired :message['star'] }
  end
  
  with_stimulus :reverse['rats'] do
    it { should have_fired :message['star'], subject }
  end
  
  with_stimulus :reverse['rats'] do
    it { should have_fired :message['star'], subject }
  end
  
  context "with multiple Wires context inclusions" do
    include_context "with Wires"
    include_context "with Wires"
    include_context "with Wires"
    include_context "with Wires"
    
    before { fire :nothing, 'nowhere' }
    it "picks up a fired event only once" do
      expect(wires_events.count).to eq 1
    end
  end
end



# describe Wires::Test::Helper do
  
  
  # include Wires::Convenience
  # include Wires::Test::Helper
  
  # it 'tracks all events fired in each test' do
  #   @received_wires_events.must_equal []
    
  #   fire :event
  #   @received_wires_events.size.must_equal 1
  #   event, chan = @received_wires_events[0]
  #   event.must_be_instance_of Wires::Event
  #   chan .must_be_instance_of Wires::Channel
    
  #   20.times do fire :event end
  #   @received_wires_events.size.must_equal 21
    
  #   fire SomeEvent; fire [SomeEvent=>[33,22,kwarg:'dog']]
  #   @received_wires_events.size.must_equal 23
  #   @received_wires_events.select{|x| x[0].is_a? SomeEvent}
  #                         .size.must_equal 2
    
  #   fire :event, 'some_channel'
  #   fire :event, 'some_channel'
  #   @received_wires_events.size.must_equal 25
  #   @received_wires_events.select{|x| x[1]==Wires::Channel.new('some_channel')}
  #                         .size.must_equal 2
  # end
  
  # it 'includes events fired with fire! (blocking)' do
  #   @received_wires_events.must_equal []
    
  #   fire! :event
  #   @received_wires_events.size.must_equal 1
  #   event, chan = @received_wires_events[0]
  #   event.must_be_instance_of Wires::Event
  #   chan .must_be_instance_of Wires::Channel
  # end
  
  # it 'will not remember events from other tests' do
  #   @received_wires_events.must_equal []
  #   fire :event
  #   @received_wires_events.size.must_equal 1
  # end
  
  # describe '00 #clear_fired' do
  #   it "clears the list of stored event/channel pairs" do
  #     @received_wires_events.must_equal []      
  #     fire :event
  #     @received_wires_events.size.must_equal 1
  #     clear_fired
  #     @received_wires_events.size.must_equal 0
  #     20.times { fire :event }
  #     @received_wires_events.size.must_equal 20
  #     clear_fired
  #     @received_wires_events.size.must_equal 0
  #   end
  # end
  
  # describe '01 #fired?' do
  #   it "can be used to match against the stored list" do
  #     fire              :event, 'channel'
  #     assert fired?     :event, 'channel'
  #     refute fired?     :event
  #     refute fired?     :event, self
  #     assert fired?     :event, '*'
  #     refute fired?     :event, 'channel2'
  #   end
    
  #   it "matches event subclasses by default" do
  #     fire SomeEvent
  #     assert fired?  Wires::Event
  #     assert fired?  SomeEvent
  #     refute fired?  SomeOtherEvent
  #     assert fired?  Wires::Event.new
  #     assert fired?  SomeEvent.new
  #     refute fired?  SomeOtherEvent.new
  #   end
    
  #   it "can match an exact event_type instead of including subclasses" do
  #     fire SomeEvent
  #     refute fired?  Wires::Event,       exact_event:true
  #     assert fired?  SomeEvent,          exact_event:true
  #     refute fired?  SomeOtherEvent,     exact_event:true
  #     refute fired?  Wires::Event.new,   exact_event:true
  #     assert fired?  SomeEvent.new,      exact_event:true
  #     refute fired?  SomeOtherEvent.new, exact_event:true
  #   end
    
  #   it "matches all channels for which the key channel is relevant" do
  #     fire           :event, 'channel'
  #     assert fired?  :event, /han/
  #     refute fired?  :event, /^han/
  #     assert fired?  :event, /(ch|fl)an+e_*l$/
  #     refute fired?  :event, /(pl|fl)an+e_*l$/
  #   end
    
  #   it "can match an exact channel instead of by relevance" do
  #     fire           :event, 'channel'
  #     assert fired?  :event, /han/
  #     refute fired?  :event, /^han/
  #     assert fired?  :event, /(ch|fl)an+e_*l$/
  #     refute fired?  :event, /(pl|fl)an+e_*l$/
  #   end
    
  #   it "can clear the list after checking for a match" do
  #     fire :symb, 'chan'
  #     assert fired?  :symb, 'chan', clear:true
  #     refute fired?  :symb, 'chan'
  #   end
    
  #   it "can test that no non-matching events were fired" do
  #     fire :symb, 'chan'
  #     assert fired? :symb, 'chan', exclusive:true
      
  #     clear_fired
  #     fire :symb, 'chan'
  #     fire :symb, 'chan'
  #     assert fired? :symb, 'chan', exclusive:true
      
  #     clear_fired
  #     fire :symb, 'chan'
  #     fire :symb, 'chan2'
  #     refute fired? :symb, 'chan', exclusive:true
      
  #     clear_fired
  #     fire :event, 'chan'
  #     fire :symb, 'chan'
  #     refute fired? :symb, 'chan', exclusive:true
  #   end
    
  #   it "can test the plurality of matching events" do
  #     fire :symb, 'chan'
  #     assert fired? :symb, 'chan', plurality:1
      
  #     clear_fired
  #     fire :symb, 'chan'
  #     fire :symb, 'chan'
  #     assert fired? :symb, 'chan', plurality:2
  #     refute fired? :symb, 'chan', plurality:1
  #     refute fired? :symb, 'chan', plurality:3
  #   end
    
  #   it "can match event parameters by array notation" do
  #     fire          [symb:[11, 22.2, :symbol, kwarg1:'one', kwarg2:2]]
      
  #     assert fired? [symb:[11]]
  #     assert fired? [symb:[11, 22.2]]
  #     assert fired? [symb:[11, 22.2, :symbol]]
      
  #     refute fired? [symb:[22.2]]
  #     refute fired? [symb:[:symbol]]
      
  #     assert fired? [symb:[kwarg1:'one']]
  #     assert fired? [symb:[kwarg1:'one', kwarg2:2]]
  #     assert fired? [symb:[kwarg2:2]]
      
  #     assert fired? [symb:[11, kwarg1:'one']]
  #     assert fired? [symb:[11, 22.2, kwarg1:'one', kwarg2:2]]
  #     assert fired? [symb:[11, 22.2, :symbol, kwarg2:2]]
  #     assert fired? [symb:[11, 22.2, :symbol, kwarg1:'one']]
  #     assert fired? [symb:[11, 22.2, :symbol, kwarg1:'one', kwarg2:2]]
  #     assert fired? [symb:[11, 22.2, :symbol, kwarg2:2]]
      
  #     refute fired? [symb:[kwarg3:'three']]
  #   end
    
  #   it "can execute a given block on all matching events" do
  #     fire [symb:[10, 55, 33, 88]], 'chan'
  #     count = 0
  #     fired? :symb, 'chan' do |e,c|
  #       count += 1
  #       e.args.each {|i| assert i>=10}
  #     end
  #     refute count.zero?
  #   end
  # end
  
  # describe '02 #assert_fired' do
  #   it "passes all args (including &block) to #fired? and asserts the result" do
  #     fire [symb:[10, 55, 33, 88]], 'chan'
  #     count = 0
  #     assert_fired :symb, /^ch.n$/, exclusive:true do |e,c|
  #       count += 1
  #       e.args.each {|i| assert i>=10}
  #     end
  #     refute count.zero?
  #   end
  # end
  
  # describe '03 #refute_fired' do
  #   it "passes all args (including &block) to #fired? and refutes the result" do
  #     fire [symb:[10, 55, 33, 88]], 'chan'
  #     count = 0
  #     refute_fired :symb_2, /^ch.n$/, clear:true do |e,c|
  #       count += 1
  #       e.args.each {|i| assert i>=10}
  #     end
  #     refute_fired :symb, /^ch.n$/ do |e,c|
  #       count += 1
  #       e.args.each {|i| assert i>=10}
  #     end
  #     assert count.zero?
  #   end
  # end
  
# end

# module UserModule
#   Wires::Util.build_alt "::#{self}::AltWires"
#   Wires::Test.build_alt "::#{self}::AltWires", affix:'alt'
#   AltWires.extend AltWires::Convenience
# end

# describe Wires::Test do
  
#   describe ".build_alt" do
    
#     it "builds an alternate version of the Wires::Test module" do
#       module UserModule
#         Wires::Test        .wont_equal AltWires::Test
#         Wires::Test::Helper.wont_equal AltWires::Test::Helper
#       end
#     end
    
#     it "can assign an affix to all defined methods of Helper" do
#       [:clear_fired,  :fired?, 
#        :assert_fired, :refute_fired].each do |x|
#         UserModule::AltWires::Test::Helper.instance_methods.wont_include x
#       end
#       [:clear_alt_fired,  :alt_fired?, 
#        :assert_alt_fired, :refute_alt_fired].each do |x|
#         UserModule::AltWires::Test::Helper.instance_methods.must_include x
#       end
#     end
    
#     describe "crosstalk" do
#       include Wires::Convenience
#       include Wires::Test::Helper
#       include UserModule::AltWires::Test::Helper
      
#       it "doesn't crosstalk when events are fired" do
        
#         fire             :event, 'channel'
        
#         assert_fired     :event, 'channel'
#         refute_alt_fired :event, 'channel'
        
#         clear_fired
#         clear_alt_fired
        
#         UserModule::AltWires.fire :event, 'channel'
        
#         refute_fired     :event, 'channel'
#         assert_alt_fired :event, 'channel'
        
#         clear_fired
#         clear_alt_fired
        
#       end
#     end
    
#   end
  
# end