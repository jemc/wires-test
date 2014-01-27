
require 'wires'
require 'wires/test'

require 'spec_helper'


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



describe TestObject, wires:true do
  its(:touched) { should_not be }
  
  context "with explicit shared context include" do
    include_context "with wires stimulus", :touch
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
    it { should have_fired :message['star'], subject }
  end
  
  with_stimulus :reverse['rats'] do
    it { should_not have_fired :message['star'], 'other' }
  end
  
  it "can execute the block given to where for each event found" do
    fire! :reverse['rats'], subject
    fire! :reverse['rats'], subject
    fire! :reverse['rats'], subject
    executed = 0
    should have_fired(:message['star']).where { |e|
      e.args.first.should eq 'star'
      executed += 1
      nil
    }
    executed.should eq 3
  end
  
  it "can use the block given to fulfilling to narrow the detection terms" do
    fire! :reverse['rats'], subject
    fire! :reverse['rats'], subject
    fire! :reverse['rats'], subject
    executed = 0
    should_not have_fired(:message['star']).fulfilling { |e|
      e.args.first.should eq 'star'
      executed += 1
      nil
    }
    executed.should eq 3
  end
  
  it "can specify how many times to expect the message" do
    fire! :reverse['rats'], subject
    fire! :reverse['rats'], subject
    fire! :reverse['rats'], subject
    should have_fired(:message['star']).exactly(3).times
  end
  
  it "can specify how many times not to expect the message" do
    fire! :reverse['rats'], subject
    fire! :reverse['rats'], subject
    should_not have_fired(:message['star']).exactly(3).times
  end
  
  it "expect the message just once" do
    fire! :reverse['rats'], subject
    should have_fired(:message['star']).once
  end
  
  it "expect the message not once" do
    fire! :reverse['rats'], subject
    fire! :reverse['rats'], subject
    should_not have_fired(:message['star']).once
  end
  
  it "expect the message just twice" do
    fire! :reverse['rats'], subject
    fire! :reverse['rats'], subject
    should have_fired(:message['star']).twice
  end
  
  it "expect the message not twice" do
    fire! :reverse['rats'], subject
    should_not have_fired(:message['star']).twice
  end
  
  context "with multiple wires context inclusions" do
    include_context "with wires"
    include_context "with wires"
    include_context "with wires"
    include_context "with wires"
    
    before { fire :nothing, 'nowhere' }
    it "picks up a fired event only once" do
      expect(wires_events.count).to eq 1
    end
  end
end



describe Wires::Test::Helper, wires:true do
  
  it 'tracks all events fired in each test' do
    @wires_events.should eq []
    
    fire :event
    @wires_events.size.should eq 1
    event, chan = @wires_events[0]
    expect(event).to eq :event
    expect(chan).to eq self
    
    20.times do fire :event end
    @wires_events.size.should eq 21
    
    fire :some_event; fire :some_event[33,22,kwarg:'dog']
    @wires_events.size.should eq 23
    @wires_events.select{|x| x[0].type == :some_event }.size.should eq 2
    
    fire :event, 'some_channel'
    fire :event, 'some_channel'
    @wires_events.size.should eq 25
    @wires_events.select{|x| x[1]=='some_channel'}.size.should eq 2
  end
  
  it 'includes events fired with fire! (blocking)' do
    @wires_events.should eq []
    
    fire! :event
    @wires_events.size.should eq 1
    event, chan = @wires_events[0]
    expect(event).to eq :event
    expect(chan).to eq self
  end
  
  it 'will not remember events from other tests' do
    @wires_events.should eq []
    fire :event
    @wires_events.size.should eq 1
  end
  
  describe '00 #clear_fired' do
    it "clears the list of stored event/channel pairs" do
      @wires_events.should eq []      
      fire :event
      @wires_events.size.should eq 1
      clear_fired
      @wires_events.size.should eq 0
      20.times { fire :event }
      @wires_events.size.should eq 20
      clear_fired
      @wires_events.size.should eq 0
    end
  end
  
  describe '01 #fired?' do
    
    let(:test_events) { [
      :event,         :event[1],         :event[1,2,3], 
      :event[kw:'a'], :event[1, kw:'a'], :event[1,2,3, kw:'a'],
      :other,         :other[1],         :other[1,2,3], 
      :other[kw:'a'], :other[1, kw:'a'], :other[1,2,3, kw:'a']
    ].map(&:to_wires_event) }
    
    let(:test_channels) { [
      'channel', /han/, /^han/, 
      /(ch|fl)an+e_*l$/, /(pl|fl)an+e_*l$/
    ].map { |name| Wires::Channel[name] } }
    
    it "can be used to match against the stored list" do
      fire   :event, 'channel'
      fired?(:event)            .should be
      fired?(:event, 'channel') .should be
      fired?(:event, 'channel2').should_not be
      fired?(:event, self)      .should_not be
    end
    
    it "matches using Event#=~ by default" do
      test_events.each do |e_fired|
        test_events.each do |e_test|
          expected_result = e_test =~ e_fired
          fire e_fired
          expect(fired? e_test).to eq expected_result
          clear_fired
        end
      end
    end
    
    it "matches using Event#== when exact_event:true is specified" do
      test_events.each do |e_fired|
        test_events.each do |e_test|
          expected_result = e_test == e_fired
          fire e_fired
          expect(fired? e_test, exact_event:true).to eq expected_result
          clear_fired
        end
      end
    end
    
    it "matches using Channel#=~ by default" do
      test_channels.each do |c_fired|
        unless c_fired.not_firable
          test_channels.each do |c_test|
            expected_result = c_test =~ c_fired
            fire :event, c_fired
            expect(fired? :event, c_test).to eq expected_result
            clear_fired
          end
        end
      end
    end
    
    it "matches using Channel#== when exact_channel:true is specified" do
      test_channels.each do |c_fired|
        unless c_fired.not_firable
          test_channels.each do |c_test|
            expected_result = c_test == c_fired
            fire :event, c_fired
            expect(fired? :event, c_test, exact_channel:true).to eq expected_result
            clear_fired
          end
        end
      end
    end
    
    it "matches both event and channel simultaneously" do
      test_events.each do |e_fired|
        test_events.each do |e_test|
          test_channels.each do |c_fired|
            unless c_fired.not_firable
              test_channels.each do |c_test|
                expected_result = (e_test =~ e_fired) && (c_test =~ c_fired)
                fire e_fired, c_fired
                expect(fired? e_test, c_test).to eq expected_result
                clear_fired
              end
            end
          end
        end
      end
    end
    
    it "can clear the list after checking for a match with clear:true" do
      fire   :event, 'channel'
      fired?(:event, 'channel')            .should be
      fired?(:event, 'channel')            .should be
      fired?(:event, 'channel', clear:true).should be
      fired?(:event, 'channel')            .should_not be
    end
    
    it "can test that no non-matching events were fired" do
      fire :event, 'chan'
      fired?(:event, 'chan', exclusive:true).should be
      
      clear_fired
      fire :event, 'chan'
      fire :event, 'chan'
      fired?(:event, 'chan', exclusive:true).should be
      
      clear_fired
      fire :event, 'chan'
      fire :event, 'chan2'
      fired?(:event, 'chan', exclusive:true).should_not be
      
      clear_fired
      fire :other_event, 'chan'
      fire :event, 'chan'
      fired?(:event, 'chan', exclusive:true).should_not be
    end
    
    it "can test the plurality of matching events" do
      fire :symb, 'chan'
      fired?(:symb, 'chan', plurality:1).should be
      
      clear_fired
      fire :symb, 'chan'
      fire :symb, 'chan'
      fired?(:symb, 'chan', plurality:2).should be
      fired?(:symb, 'chan', plurality:1).should_not be
      fired?(:symb, 'chan', plurality:3).should_not be
    end
    
  end
end
