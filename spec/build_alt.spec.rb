
require 'wires'
require 'wires/test'

require 'spec_helper'


module UserModule
  Wires::Util.build_alt "::#{self}::AltWires"
  Wires::Test.build_alt "::#{self}::AltWires", affix:'alt'
  AltWires.extend AltWires::Convenience
end

shared_examples "a module transformed by build_alt" do
  it "it gets its instance methods replaced" do
    alt_obj = Object.new.extend alt_mod
    mod.instance_methods(false).each_with_index do |sym,i|
      expect(alt_obj).not_to respond_to sym
      expect(sym).to eq alt_mod.instance_methods(false)[i].to_s
                               .gsub(/alt_/,'').to_sym
    end
  end
  
  it "it gets its instance variables replaced" do
    obj     = Object.new.extend mod
    alt_obj = Object.new.extend alt_mod
    
    begin; obj        .wires_test_setup; rescue NoMethodError; end
    begin; alt_obj.alt_wires_test_setup; rescue NoMethodError; end
    
    obj.instance_variables.each_with_index do |sym, i|
      expect(alt_obj.instance_variables).not_to include sym
      expect(sym).to eq alt_obj.instance_variables[i].to_s
                               .gsub(/alt_/,'').to_sym
    end
  end
end

describe Wires::Test do
  
  describe ".build_alt" do
    
    it "builds an alternate version of the Wires::Test module" do
      expect(Wires::Test)        .not_to eq ::UserModule::AltWires::Test
      expect(Wires::Test::Helper).not_to eq ::UserModule::AltWires::Test::Helper
    end
    
    describe Wires::Test::Helper do
      let(:mod)     {                  Wires::Test::Helper }
      let(:alt_mod) { ::UserModule::AltWires::Test::Helper }
      it_behaves_like "a module transformed by build_alt"
    end
    
    describe Wires::Test::RSpec::ExampleGroupMethods do
      let(:mod)     {                  Wires::Test::RSpec::ExampleGroupMethods }
      let(:alt_mod) { ::UserModule::AltWires::Test::RSpec::ExampleGroupMethods }
      it_behaves_like "a module transformed by build_alt"
    end
    
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
    
  end
  
end
